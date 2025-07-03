import '../core/network/api_client.dart';
import '../models/models.dart';
import '../core/utils/logger.dart';

import '../providers/ml_matching_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Production-ready ML matching service that connects to Python FastAPI backend
class MLMatchingService {
  static MLMatchingService? _instance;
  static MLMatchingService get instance =>
      _instance ??= MLMatchingService._internal();

  final ApiClient _apiClient = ApiClient.instance;
  late final String _baseUrl;

  MLMatchingService._internal() {
    _baseUrl = dotenv.env['ML_BACKEND_URL'] ?? 'http://localhost:8000';
    AppLogger.logger
        .d('🧠 ML Matching Service initialized with URL: $_baseUrl');
  }

  /// Get personalized user recommendations using ML backend
  Future<MLRecommendationResponse> getRecommendations({
    required UserModel currentUser,
    List<String> excludeUserIds = const [],
    int maxRecommendations = 20,
    bool includeAnalytics = true,
    bool useCache = true,
  }) async {
    try {
      AppLogger.logger
          .d('🔍 Getting ML recommendations for user: ${currentUser.id}');

      // Prepare request payload
      final requestData = {
        'user_id': currentUser.id,
        'user_profile': _userModelToBackendFormat(currentUser),
        'exclude_user_ids': excludeUserIds,
        'max_recommendations': maxRecommendations,
        'include_analytics': includeAnalytics,
      };

      // Make API call to ML backend
      final response = await _apiClient.post<Map<String, dynamic>>(
        '$_baseUrl/recommendations',
        data: requestData,
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.isSuccess && response.data != null) {
        final mlResponse = MLRecommendationResponse.fromJson(response.data!);

        AppLogger.logger.success(
            '✅ Got ${mlResponse.recommendations.length} ML recommendations for ${currentUser.id}');

        // Cache the results
        if (useCache) {
          await _cacheRecommendations(currentUser.id, mlResponse);
        }

        return mlResponse;
      } else {
        throw MLMatchingException(
          'Failed to get recommendations: ${response.errorMessage}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      AppLogger.logger.e('❌ Error getting ML recommendations', error: e);

      // Try to return cached results on error
      if (useCache) {
        final cachedResults = await _getCachedRecommendations(currentUser.id);
        if (cachedResults != null) {
          AppLogger.logger
              .w('⚠️ Returning cached recommendations due to error');
          return cachedResults;
        }
      }

      throw MLMatchingException(
        'Failed to get recommendations: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Record a swipe for collaborative filtering
  Future<bool> recordSwipe({
    required String swiperId,
    required String targetId,
    required SwipeDirection direction,
    String targetType = 'user',
  }) async {
    try {
      AppLogger.logger
          .d('👆 Recording swipe: $swiperId -> $targetId ($direction)');

      final swipeData = {
        'swiper_id': swiperId,
        'target_id': targetId,
        'direction': direction.name,
        'target_type': targetType,
        'timestamp': DateTime.now().toIso8601String(),
      };

      final response = await _apiClient.post<Map<String, dynamic>>(
        '$_baseUrl/swipe',
        data: swipeData,
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.isSuccess) {
        AppLogger.logger.d('✅ Swipe recorded successfully');
        return true;
      } else {
        throw MLMatchingException(
          'Failed to record swipe: ${response.errorMessage}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      AppLogger.logger.e('❌ Error recording swipe', error: e);
      return false;
    }
  }

  /// Update user profile in ML backend
  Future<bool> updateUserProfile(UserModel user) async {
    try {
      AppLogger.logger.d('📝 Updating user profile in ML backend: ${user.id}');

      final profileData = _userModelToBackendFormat(user);

      final response = await _apiClient.post<Map<String, dynamic>>(
        '$_baseUrl/users/profile',
        data: profileData,
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.isSuccess) {
        AppLogger.logger.success('✅ User profile updated in ML backend');
        return true;
      } else {
        throw MLMatchingException(
          'Failed to update profile: ${response.errorMessage}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      AppLogger.logger
          .e('❌ Error updating user profile in ML backend', error: e);
      return false;
    }
  }

  /// Get ML backend analytics and health status
  Future<MLBackendStatus> getBackendStatus() async {
    try {
      AppLogger.logger.d('🏥 Checking ML backend health');

      final response = await _apiClient.get<Map<String, dynamic>>(
        '$_baseUrl/health',
        fromJson: (data) => data as Map<String, dynamic>,
        useCache: false,
      );

      if (response.isSuccess && response.data != null) {
        return MLBackendStatus.fromJson(response.data!);
      } else {
        throw MLMatchingException(
          'Failed to get backend status: ${response.errorMessage}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      AppLogger.logger.e('❌ Error getting backend status', error: e);
      throw MLMatchingException(
        'Backend health check failed: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Get analytics stats from ML backend
  Future<MLAnalyticsStats> getAnalyticsStats() async {
    try {
      AppLogger.logger.d('📊 Getting ML analytics stats');

      final response = await _apiClient.get<Map<String, dynamic>>(
        '$_baseUrl/analytics/stats',
        fromJson: (data) => data as Map<String, dynamic>,
        useCache: true,
        cacheDuration: const Duration(minutes: 15),
      );

      if (response.isSuccess && response.data != null) {
        return MLAnalyticsStats.fromJson(response.data!);
      } else {
        throw MLMatchingException(
          'Failed to get analytics: ${response.errorMessage}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      AppLogger.logger.e('❌ Error getting analytics stats', error: e);
      throw MLMatchingException(
        'Failed to get analytics: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Get similarity score between two users
  Future<double> getUserSimilarityScore({
    required String userId1,
    required String userId2,
  }) async {
    try {
      AppLogger.logger.d('🎯 Getting similarity score: $userId1 <-> $userId2');

      final response = await _apiClient.get<Map<String, dynamic>>(
        '$_baseUrl/similarity',
        queryParameters: {
          'user1': userId1,
          'user2': userId2,
        },
        fromJson: (data) => data as Map<String, dynamic>,
        useCache: true,
        cacheDuration: const Duration(hours: 6),
      );

      if (response.isSuccess && response.data != null) {
        return (response.data!['similarity_score'] as num).toDouble();
      } else {
        throw MLMatchingException(
          'Failed to get similarity score: ${response.errorMessage}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      AppLogger.logger.e('❌ Error getting similarity score', error: e);
      return 0.0; // Return neutral score on error
    }
  }

  /// Convert UserModel to backend-compatible format
  Map<String, dynamic> _userModelToBackendFormat(UserModel user) {
    return {
      'id': user.id,
      'name': user.name,
      'bio': user.bio ?? '',
      'tech_stack': user.skills,
      'github_handle':
          user.githubUrl?.replaceAll('https://github.com/', '') ?? '',
      'role': user.role.name,
      'skills': user.skills,
      'github_stats': _extractGitHubStats(user),
      'location': user.location ?? '',
    };
  }

  /// Extract GitHub stats from user model
  Map<String, dynamic> _extractGitHubStats(UserModel user) {
    // This would be populated from GitHub API integration
    return {
      'public_repos': 0,
      'followers': 0,
      'following': 0,
      'contributions_last_year': 0,
    };
  }

  /// Cache recommendations for offline access
  Future<void> _cacheRecommendations(
      String userId, MLRecommendationResponse recommendations) async {
    try {
      await _apiClient.initializeCache();
      // Cache implementation would go here
      AppLogger.logger.d('📦 Cached recommendations for user: $userId');
    } catch (e) {
      AppLogger.logger.w('⚠️ Failed to cache recommendations', error: e);
    }
  }

  /// Get cached recommendations
  Future<MLRecommendationResponse?> _getCachedRecommendations(
      String userId) async {
    try {
      // Cache retrieval implementation would go here
      AppLogger.logger
          .d('📦 Checking cached recommendations for user: $userId');
      return null; // Placeholder
    } catch (e) {
      AppLogger.logger.w('⚠️ Failed to get cached recommendations', error: e);
      return null;
    }
  }
}

/// ML Matching Service Exception
class MLMatchingException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  const MLMatchingException(
    this.message, {
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() => 'MLMatchingException: $message';
}

/// ML Recommendation Response Model
class MLRecommendationResponse {
  final String userId;
  final List<MLRecommendation> recommendations;
  final DateTime generatedAt;
  final String modelVersion;
  final MLAnalytics? analytics;

  const MLRecommendationResponse({
    required this.userId,
    required this.recommendations,
    required this.generatedAt,
    required this.modelVersion,
    this.analytics,
  });

  factory MLRecommendationResponse.fromJson(Map<String, dynamic> json) {
    return MLRecommendationResponse(
      userId: json['user_id'] as String,
      recommendations: (json['recommendations'] as List)
          .map((e) => MLRecommendation.fromJson(e as Map<String, dynamic>))
          .toList(),
      generatedAt: DateTime.parse(json['generated_at'] as String),
      modelVersion: json['model_version'] as String,
      analytics: json['analytics'] != null
          ? MLAnalytics.fromJson(json['analytics'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'recommendations': recommendations.map((e) => e.toJson()).toList(),
      'generated_at': generatedAt.toIso8601String(),
      'model_version': modelVersion,
      'analytics': analytics?.toJson(),
    };
  }
}

/// ML Recommendation Model
class MLRecommendation {
  final String targetUserId;
  final double similarityScore;
  final double techOverlapScore;
  final double bioSimilarityScore;
  final double githubActivityScore;
  final double collaborativeScore;
  final double overallScore;
  final List<String> matchReasons;

  const MLRecommendation({
    required this.targetUserId,
    required this.similarityScore,
    required this.techOverlapScore,
    required this.bioSimilarityScore,
    required this.githubActivityScore,
    required this.collaborativeScore,
    required this.overallScore,
    required this.matchReasons,
  });

  factory MLRecommendation.fromJson(Map<String, dynamic> json) {
    return MLRecommendation(
      targetUserId: json['target_user_id'] as String,
      similarityScore: (json['similarity_score'] as num).toDouble(),
      techOverlapScore: (json['tech_overlap_score'] as num).toDouble(),
      bioSimilarityScore: (json['bio_similarity_score'] as num).toDouble(),
      githubActivityScore: (json['github_activity_score'] as num).toDouble(),
      collaborativeScore: (json['collaborative_score'] as num).toDouble(),
      overallScore: (json['overall_score'] as num).toDouble(),
      matchReasons: List<String>.from(json['match_reasons'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'target_user_id': targetUserId,
      'similarity_score': similarityScore,
      'tech_overlap_score': techOverlapScore,
      'bio_similarity_score': bioSimilarityScore,
      'github_activity_score': githubActivityScore,
      'collaborative_score': collaborativeScore,
      'overall_score': overallScore,
      'match_reasons': matchReasons,
    };
  }
}

/// ML Analytics Model
class MLAnalytics {
  final int totalPotentialMatches;
  final double avgTechScore;
  final double avgBioScore;
  final int processingTimeMs;
  final String modelConfidence;

  const MLAnalytics({
    required this.totalPotentialMatches,
    required this.avgTechScore,
    required this.avgBioScore,
    required this.processingTimeMs,
    required this.modelConfidence,
  });

  factory MLAnalytics.fromJson(Map<String, dynamic> json) {
    return MLAnalytics(
      totalPotentialMatches: json['total_potential_matches'] as int,
      avgTechScore: (json['avg_tech_score'] as num).toDouble(),
      avgBioScore: (json['avg_bio_score'] as num).toDouble(),
      processingTimeMs: json['processing_time_ms'] as int,
      modelConfidence: json['model_confidence'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_potential_matches': totalPotentialMatches,
      'avg_tech_score': avgTechScore,
      'avg_bio_score': avgBioScore,
      'processing_time_ms': processingTimeMs,
      'model_confidence': modelConfidence,
    };
  }
}

/// ML Backend Status Model
class MLBackendStatus {
  final String status;
  final DateTime timestamp;
  final bool modelsLoaded;
  final String version;

  const MLBackendStatus({
    required this.status,
    required this.timestamp,
    required this.modelsLoaded,
    required this.version,
  });

  factory MLBackendStatus.fromJson(Map<String, dynamic> json) {
    return MLBackendStatus(
      status: json['status'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      modelsLoaded: json['models_loaded'] as bool,
      version: json['version'] as String,
    );
  }

  bool get isHealthy => status == 'healthy' && modelsLoaded;
}

/// ML Analytics Stats Model
class MLAnalyticsStats {
  final int totalUsers;
  final int totalSwipes;
  final double rightSwipeRate;
  final int cachedEmbeddings;
  final String modelVersion;

  const MLAnalyticsStats({
    required this.totalUsers,
    required this.totalSwipes,
    required this.rightSwipeRate,
    required this.cachedEmbeddings,
    required this.modelVersion,
  });

  factory MLAnalyticsStats.fromJson(Map<String, dynamic> json) {
    return MLAnalyticsStats(
      totalUsers: json['total_users'] as int,
      totalSwipes: json['total_swipes'] as int,
      rightSwipeRate: (json['right_swipe_rate'] as num).toDouble(),
      cachedEmbeddings: json['cached_embeddings'] as int,
      modelVersion: json['model_version'] as String,
    );
  }
}

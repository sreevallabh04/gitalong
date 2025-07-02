import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../models/swipe_model.dart';
import '../core/utils/logger.dart';
import '../config/app_config.dart';

/// ML Recommendation model
class MLRecommendation {
  final String targetUserId;
  final double similarityScore;
  final double techOverlapScore;
  final double bioSimilarityScore;
  final double githubActivityScore;
  final double collaborativeScore;
  final double overallScore;
  final List<String> matchReasons;
  final UserModel? targetUser; // Populated after fetching user details

  const MLRecommendation({
    required this.targetUserId,
    required this.similarityScore,
    required this.techOverlapScore,
    required this.bioSimilarityScore,
    required this.githubActivityScore,
    required this.collaborativeScore,
    required this.overallScore,
    required this.matchReasons,
    this.targetUser,
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
      matchReasons: List<String>.from(json['match_reasons'] ?? []),
    );
  }

  MLRecommendation copyWith({
    String? targetUserId,
    double? similarityScore,
    double? techOverlapScore,
    double? bioSimilarityScore,
    double? githubActivityScore,
    double? collaborativeScore,
    double? overallScore,
    List<String>? matchReasons,
    UserModel? targetUser,
  }) {
    return MLRecommendation(
      targetUserId: targetUserId ?? this.targetUserId,
      similarityScore: similarityScore ?? this.similarityScore,
      techOverlapScore: techOverlapScore ?? this.techOverlapScore,
      bioSimilarityScore: bioSimilarityScore ?? this.bioSimilarityScore,
      githubActivityScore: githubActivityScore ?? this.githubActivityScore,
      collaborativeScore: collaborativeScore ?? this.collaborativeScore,
      overallScore: overallScore ?? this.overallScore,
      matchReasons: matchReasons ?? this.matchReasons,
      targetUser: targetUser ?? this.targetUser,
    );
  }

  @override
  String toString() =>
      'MLRecommendation(targetUserId: $targetUserId, overallScore: $overallScore)';
}

/// ML Analytics model
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
}

/// ML Matching Service for AI-powered developer matching
class MLMatchingService {
  static const String _baseUrl =
      'http://localhost:8000'; // In production: 'https://api.gitalong.dev'
  late final Dio _dio;

  MLMatchingService() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add interceptors for logging and error handling
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        AppLogger.logger
            .network('🌐 ML API Request: ${options.method} ${options.path}');
        handler.next(options);
      },
      onResponse: (response, handler) {
        AppLogger.logger.network(
            '✅ ML API Response: ${response.statusCode} ${response.requestOptions.path}');
        handler.next(response);
      },
      onError: (error, handler) {
        AppLogger.logger.e('❌ ML API Error: ${error.message}', error: error);
        handler.next(error);
      },
    ));
  }

  /// Check if ML backend is healthy
  Future<bool> isHealthy() async {
    try {
      final response = await _dio.get('/health');
      final isHealthy =
          response.statusCode == 200 && response.data['status'] == 'healthy';

      AppLogger.logger.network(
          isHealthy ? '✅ ML backend is healthy' : '⚠️ ML backend unhealthy');
      return isHealthy;
    } catch (e) {
      AppLogger.logger.w('⚠️ ML backend health check failed: $e');
      return false;
    }
  }

  /// Update user profile in ML backend
  Future<void> updateUserProfile(UserModel user) async {
    try {
      AppLogger.logger.network('📝 Updating ML profile for: ${user.name}');

      final profileData = {
        'id': user.id,
        'name': user.name,
        'bio': user.bio ?? '',
        'tech_stack': user.skills,
        'github_handle': _extractGitHubHandle(user.githubUrl),
        'role': user.role.name,
        'skills': user.skills,
        'github_stats':
            _generateGitHubStats(), // TODO: Replace with real GitHub API data
        'location': '', // TODO: Add location field to UserModel
      };

      final response = await _dio.post('/users/profile', data: profileData);

      if (response.statusCode == 200) {
        AppLogger.logger.success('✅ ML profile updated successfully');
      } else {
        throw Exception('Failed to update ML profile: ${response.statusCode}');
      }
    } on DioException catch (e) {
      AppLogger.logger.e('❌ Failed to update ML profile', error: e);
      throw _handleDioError(e, 'Failed to update profile in ML backend');
    } catch (e) {
      AppLogger.logger.e('❌ Unexpected error updating ML profile', error: e);
      throw Exception('Failed to update ML profile: $e');
    }
  }

  /// Get ML-powered recommendations for a user
  Future<List<MLRecommendation>> getRecommendations({
    required UserModel user,
    List<String> excludeUserIds = const [],
    int maxRecommendations = 20,
    bool includeAnalytics = true,
  }) async {
    try {
      AppLogger.logger
          .network('🤖 Fetching ML recommendations for: ${user.name}');

      // Ensure user profile is up to date in ML backend
      await updateUserProfile(user);

      final requestData = {
        'user_id': user.id,
        'user_profile': {
          'id': user.id,
          'name': user.name,
          'bio': user.bio ?? '',
          'tech_stack': user.skills,
          'github_handle': _extractGitHubHandle(user.githubUrl),
          'role': user.role.name,
          'skills': user.skills,
          'github_stats': _generateGitHubStats(),
          'location': '',
        },
        'exclude_user_ids': excludeUserIds,
        'max_recommendations': maxRecommendations,
        'include_analytics': includeAnalytics,
      };

      final response = await _dio.post('/recommendations', data: requestData);

      if (response.statusCode == 200) {
        final data = response.data;
        final recommendationsList = data['recommendations'] as List;

        final recommendations = recommendationsList
            .map((json) => MLRecommendation.fromJson(json))
            .toList();

        AppLogger.logger
            .success('✅ Fetched ${recommendations.length} ML recommendations');
        return recommendations;
      } else {
        throw Exception(
            'Failed to get recommendations: ${response.statusCode}');
      }
    } on DioException catch (e) {
      AppLogger.logger.e('❌ Failed to get ML recommendations', error: e);
      throw _handleDioError(e, 'Failed to get recommendations from ML backend');
    } catch (e) {
      AppLogger.logger
          .e('❌ Unexpected error getting ML recommendations', error: e);
      throw Exception('Failed to get ML recommendations: $e');
    }
  }

  /// Record a swipe for ML training
  Future<void> recordSwipe(SwipeModel swipe) async {
    try {
      AppLogger.logger.network(
          '👆 Recording swipe for ML: ${swipe.swiperId} -> ${swipe.targetId}');

      final swipeData = {
        'swiper_id': swipe.swiperId,
        'target_id': swipe.targetId,
        'direction': swipe.direction.name,
        'timestamp': swipe.createdAt.toIso8601String(),
      };

      final response = await _dio.post('/swipe', data: swipeData);

      if (response.statusCode == 200) {
        AppLogger.logger.success('✅ Swipe recorded for ML training');
      } else {
        throw Exception('Failed to record swipe: ${response.statusCode}');
      }
    } on DioException catch (e) {
      AppLogger.logger.e('❌ Failed to record swipe', error: e);
      // Don't throw here - swipe recording is not critical for user experience
      AppLogger.logger.w('⚠️ Continuing without ML swipe recording');
    } catch (e) {
      AppLogger.logger.e('❌ Unexpected error recording swipe', error: e);
      // Don't throw here - swipe recording is not critical
    }
  }

  /// Get ML analytics and stats
  Future<MLAnalytics?> getAnalytics() async {
    try {
      AppLogger.logger.network('📊 Fetching ML analytics');

      final response = await _dio.get('/analytics/stats');

      if (response.statusCode == 200) {
        AppLogger.logger.success('✅ ML analytics fetched');
        return MLAnalytics.fromJson(response.data);
      } else {
        throw Exception('Failed to get analytics: ${response.statusCode}');
      }
    } on DioException catch (e) {
      AppLogger.logger.e('❌ Failed to get ML analytics', error: e);
      return null; // Return null instead of throwing for analytics
    } catch (e) {
      AppLogger.logger.e('❌ Unexpected error getting ML analytics', error: e);
      return null;
    }
  }

  /// Extract GitHub handle from URL
  String? _extractGitHubHandle(String? githubUrl) {
    if (githubUrl == null || githubUrl.isEmpty) return null;

    final uri = Uri.tryParse(githubUrl);
    if (uri == null || !uri.host.contains('github.com')) return null;

    final pathSegments = uri.pathSegments;
    if (pathSegments.isNotEmpty) {
      return pathSegments.first;
    }

    return null;
  }

  /// Generate mock GitHub stats (TODO: Replace with real GitHub API integration)
  Map<String, dynamic> _generateGitHubStats() {
    // In production, this would call GitHub API
    return {
      'public_repos': 15 + (DateTime.now().millisecondsSinceEpoch % 30),
      'followers': 50 + (DateTime.now().millisecondsSinceEpoch % 200),
      'contributions_last_year':
          100 + (DateTime.now().millisecondsSinceEpoch % 400),
    };
  }

  /// Handle Dio errors and provide user-friendly messages
  Exception _handleDioError(DioException error, String context) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception(
            '$context: Request timed out. Please check your connection.');

      case DioExceptionType.connectionError:
        return Exception(
            '$context: Network error. Please check your internet connection.');

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 404) {
          return Exception(
              '$context: Service not found. Please try again later.');
        } else if (statusCode == 500) {
          return Exception('$context: Server error. Please try again later.');
        } else if (statusCode == 503) {
          return Exception('$context: Service temporarily unavailable.');
        }
        return Exception('$context: Server returned error $statusCode.');

      case DioExceptionType.cancel:
        return Exception('$context: Request was cancelled.');

      case DioExceptionType.unknown:
      default:
        return Exception('$context: An unexpected error occurred.');
    }
  }

  /// Dispose resources
  void dispose() {
    _dio.close();
  }
}

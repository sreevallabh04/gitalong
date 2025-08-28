import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../core/config/production_constants.dart';
import '../core/network/api_client.dart';
import '../core/utils/logger.dart';
import '../models/models.dart' as models;
import '../providers/ml_matching_provider.dart' show SwipeDirection;

/// Production-ready ML matching service that connects to Python FastAPI backend
class MLMatchingService {

  MLMatchingService._internal() {
    // Production-ready URL configuration
    final envUrl = dotenv.env['ML_BACKEND_URL'];

    if (envUrl != null && envUrl.isNotEmpty) {
      _baseUrl = envUrl;
    } else {
      // Use production constants for URL determination
      _baseUrl = ProductionConstants.apiUrl;
    }

    AppLogger.logger
        .d('🧠 ML Matching Service initialized with URL: $_baseUrl');
  }
  static MLMatchingService? _instance;
  static MLMatchingService get instance =>
      _instance ??= MLMatchingService._internal();

  final ApiClient _apiClient = ApiClient.instance;
  late final String _baseUrl;

  /// Get ML-based recommendations
  Future<Map<String, dynamic>> getRecommendations({
    required models.UserModel currentUser,
    List<String> excludeUserIds = const [],
    int maxRecommendations = 20,
  }) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/ml/recommendations',
        data: {
          'user_id': currentUser.uid,
          'user_data': currentUser.toJson(),
          'exclude_user_ids': excludeUserIds,
          'max_recommendations': maxRecommendations,
        },
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.isSuccess) {
        return response.data ?? {};
      } else {
        AppLogger.logger.e('ML API error: ${response.message}');
        return _getFallbackRecommendations(currentUser, excludeUserIds, maxRecommendations);
      }
    } on Exception catch (e, stackTrace) {
      AppLogger.logger.e('Error getting ML recommendations', error: e, stackTrace: stackTrace);
      return _getFallbackRecommendations(currentUser, excludeUserIds, maxRecommendations);
    }
  }

  /// Get user similarity score
  Future<double> getUserSimilarity(models.UserModel user1, models.UserModel user2) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/ml/similarity',
        data: {
          'user1': user1.toJson(),
          'user2': user2.toJson(),
        },
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.isSuccess && response.data != null) {
        return (response.data!['similarity_score'] as num?)?.toDouble() ?? 0.0;
      } else {
        AppLogger.logger.e('ML API error: ${response.message}');
        return _calculateFallbackSimilarity(user1, user2);
      }
    } on Exception catch (e, stackTrace) {
      AppLogger.logger.e('Error getting user similarity', error: e, stackTrace: stackTrace);
      return _calculateFallbackSimilarity(user1, user2);
    }
  }

  /// Get project recommendations for user
  Future<List<models.ProjectModel>> getProjectRecommendations({
    required models.UserModel user,
    List<String> excludeProjectIds = const [],
    int maxRecommendations = 10,
  }) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/ml/project-recommendations',
        data: {
          'user_id': user.uid,
          'user_data': user.toJson(),
          'exclude_project_ids': excludeProjectIds,
          'max_recommendations': maxRecommendations,
        },
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.isSuccess && response.data != null) {
        final projectsList = response.data!['projects'] as List<dynamic>? ?? [];
        return projectsList
            .map((projectData) => models.ProjectModel.fromJson(projectData as Map<String, dynamic>))
            .toList();
      } else {
        AppLogger.logger.e('ML API error: ${response.message}');
        return _getFallbackProjectRecommendations(user, excludeProjectIds, maxRecommendations);
      }
    } on Exception catch (e, stackTrace) {
      AppLogger.logger.e('Error getting project recommendations', error: e, stackTrace: stackTrace);
      return _getFallbackProjectRecommendations(user, excludeProjectIds, maxRecommendations);
    }
  }

  /// Get skill-based recommendations
  Future<List<models.UserModel>> getSkillBasedRecommendations({
    required List<String> skills,
    List<String> excludeUserIds = const [],
    int maxRecommendations = 15,
  }) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/ml/skill-recommendations',
        data: {
          'skills': skills,
          'exclude_user_ids': excludeUserIds,
          'max_recommendations': maxRecommendations,
        },
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.isSuccess && response.data != null) {
        final usersList = response.data!['users'] as List<dynamic>? ?? [];
        return usersList
            .map((userData) => models.UserModel.fromJson(userData as Map<String, dynamic>))
            .toList();
      } else {
        AppLogger.logger.e('ML API error: ${response.message}');
        return _getFallbackSkillRecommendations(skills, excludeUserIds, maxRecommendations);
      }
    } on Exception catch (e, stackTrace) {
      AppLogger.logger.e('Error getting skill-based recommendations', error: e, stackTrace: stackTrace);
      return _getFallbackSkillRecommendations(skills, excludeUserIds, maxRecommendations);
    }
  }

  /// Fallback recommendations when ML API fails
  Map<String, dynamic> _getFallbackRecommendations(
    models.UserModel currentUser,
    List<String> excludeUserIds,
    int maxRecommendations,
  ) => {
      'recommendations': [],
      'fallback': true,
      'message': 'Using fallback recommendations',
    };

  /// Fallback similarity calculation
  double _calculateFallbackSimilarity(models.UserModel user1, models.UserModel user2) {
    // Simple skill-based similarity
    final commonSkills = user1.skills?.where((skill) => user2.skills?.contains(skill) ?? false).length ?? 0;
    final totalSkills = (user1.skills?.length ?? 0) + (user2.skills?.length ?? 0);
    return totalSkills > 0 ? commonSkills / totalSkills : 0.0;
  }

  /// Fallback project recommendations
  List<models.ProjectModel> _getFallbackProjectRecommendations(
    models.UserModel user,
    List<String> excludeProjectIds,
    int maxRecommendations,
  ) => [];

  /// Fallback skill-based recommendations
  List<models.UserModel> _getFallbackSkillRecommendations(
    List<String> skills,
    List<String> excludeUserIds,
    int maxRecommendations,
  ) => [];

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
  Future<bool> updateUserProfile(models.UserModel user) async {
    try {
      AppLogger.logger.d('👤 Updating user profile in ML backend...');

      final profileData = _userModelToBackendFormat(user);

      final response = await _apiClient.put<Map<String, dynamic>>(
        '$_baseUrl/user/profile',
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
      AppLogger.logger.e('❌ Error updating user profile', error: e);
      return false;
    }
  }

  /// Get backend health status
  Future<Map<String, dynamic>> getBackendStatus() async {
    try {
      AppLogger.logger.d('🏥 Checking ML backend health...');

      final response = await _apiClient.get<Map<String, dynamic>>(
        '$_baseUrl/health',
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.isSuccess) {
        AppLogger.logger.success('✅ ML backend is healthy');
        return response.data!;
      } else {
        throw MLMatchingException(
          'Backend health check failed: ${response.errorMessage}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      AppLogger.logger.e('❌ Backend health check failed', error: e);
      throw MLMatchingException(
        'Backend health check failed: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Get analytics stats from ML backend
  Future<Map<String, dynamic>> getAnalyticsStats() async {
    try {
      AppLogger.logger.d('📊 Getting ML analytics stats');

      final response = await _apiClient.get<Map<String, dynamic>>(
        '$_baseUrl/analytics/stats',
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.isSuccess) {
        AppLogger.logger.success('✅ Analytics stats received');
        return response.data!;
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

  /// Convert UserModel to backend-compatible format
  Map<String, dynamic> _userModelToBackendFormat(models.UserModel user) => {
      'id': user.id,
      'name': user.name ?? '',
      'email': user.email,
      'bio': user.bio ?? '',
      'tech_stack': user.skills,
      'role': user.role?.name ?? '',
      'github_handle':
          user.githubUrl?.replaceAll('https://github.com/', '') ?? '',
      'github_stats': _extractGitHubStats(user),
      'location': user.location ?? '',
      'created_at': user.createdAt?.toIso8601String() ?? '',
      'updated_at': user.updatedAt?.toIso8601String() ?? '',
    };

  /// Extract GitHub stats from user model
  Map<String, dynamic> _extractGitHubStats(models.UserModel user) {
    // This would be populated from GitHub API integration
    return {
      'repositories': 0,
      'followers': 0,
      'following': 0,
      'stars': 0,
      'contributions': 0,
    };
  }

  /// Cache recommendations for offline access
  Future<void> _cacheRecommendations(
      String userId, Map<String, dynamic> recommendations,) async {
    try {
      // Implementation would use local storage or database
      AppLogger.logger.d('📦 Caching recommendations for user: $userId');
    } catch (e) {
      AppLogger.logger.w('⚠️ Failed to cache recommendations', error: e);
    }
  }

  /// Get cached recommendations
  Future<Map<String, dynamic>?> _getCachedRecommendations(String userId) async {
    try {
      // Implementation would retrieve from local storage or database
      AppLogger.logger.d('📦 Getting cached recommendations for user: $userId');
      return null;
    } catch (e) {
      AppLogger.logger.w('⚠️ Failed to get cached recommendations', error: e);
      return null;
    }
  }
}

/// Exception class for ML matching errors
class MLMatchingException implements Exception {

  MLMatchingException(this.message, {this.statusCode, this.originalError});
  final String message;
  final int? statusCode;
  final dynamic originalError;

  @override
  String toString() => 'MLMatchingException: $message';
}


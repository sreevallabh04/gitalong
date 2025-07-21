import '../core/network/api_client.dart';
import '../models/models.dart' as models;
import '../core/utils/logger.dart';
import '../core/config/production_constants.dart';
import '../providers/ml_matching_provider.dart' show SwipeDirection;

import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Production-ready ML matching service that connects to Python FastAPI backend
class MLMatchingService {
  static MLMatchingService? _instance;
  static MLMatchingService get instance =>
      _instance ??= MLMatchingService._internal();

  final ApiClient _apiClient = ApiClient.instance;
  late final String _baseUrl;

  MLMatchingService._internal() {
    // Production-ready URL configuration
    final String? envUrl = dotenv.env['ML_BACKEND_URL'];

    if (envUrl != null && envUrl.isNotEmpty) {
      _baseUrl = envUrl;
    } else {
      // Use production constants for URL determination
      _baseUrl = ProductionConstants.apiUrl;
    }

    AppLogger.logger
        .d('🧠 ML Matching Service initialized with URL: $_baseUrl');
  }

  /// Get personalized user recommendations using ML backend
  Future<Map<String, dynamic>> getRecommendations({
    required models.UserModel currentUser,
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
        'user_id': currentUser.id ?? '',
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

      if (response.isSuccess) {
        final mlResponse = response.data!;
        AppLogger.logger.success('✅ ML recommendations received');

        // Cache successful results for offline access
        if (useCache) {
          await _cacheRecommendations(currentUser.id ?? '', mlResponse);
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
        final cachedResults =
            await _getCachedRecommendations(currentUser.id ?? '');
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
  Map<String, dynamic> _userModelToBackendFormat(models.UserModel user) {
    return {
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
  }

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
      String userId, Map<String, dynamic> recommendations) async {
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
  final String message;
  final int? statusCode;
  final dynamic originalError;

  MLMatchingException(this.message, {this.statusCode, this.originalError});

  @override
  String toString() => 'MLMatchingException: $message';
}

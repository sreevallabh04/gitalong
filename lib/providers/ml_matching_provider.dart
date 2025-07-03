import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ml_matching_service.dart';

import '../core/utils/logger.dart';
import 'auth_provider.dart';

/// Swipe direction enum for ML matching
enum SwipeDirection {
  left,
  right;

  /// Convert boolean like to SwipeDirection
  static SwipeDirection fromLike(bool isLike) {
    return isLike ? SwipeDirection.right : SwipeDirection.left;
  }

  /// Convert SwipeDirection to boolean like
  bool get isLike => this == SwipeDirection.right;
}

/// Provider for ML matching service
final mlMatchingServiceProvider = Provider<MLMatchingService>((ref) {
  return MLMatchingService.instance;
});

/// Provider for ML recommendations
final mlRecommendationsProvider = AsyncNotifierProvider.family<
    MLRecommendationsNotifier,
    MLRecommendationResponse?,
    String>(MLRecommendationsNotifier.new);

/// Provider for ML backend status
final mlBackendStatusProvider =
    AsyncNotifierProvider<MLBackendStatusNotifier, MLBackendStatus>(
        MLBackendStatusNotifier.new);

/// Provider for ML analytics stats
final mlAnalyticsStatsProvider =
    AsyncNotifierProvider<MLAnalyticsStatsNotifier, MLAnalyticsStats>(
        MLAnalyticsStatsNotifier.new);

/// ML Recommendations Notifier - handles user recommendations with caching and error handling
class MLRecommendationsNotifier
    extends FamilyAsyncNotifier<MLRecommendationResponse?, String> {
  @override
  Future<MLRecommendationResponse?> build(String userId) async {
    // Return null initially, will be loaded when requested
    return null;
  }

  /// Get recommendations for a user
  Future<void> getRecommendations({
    List<String> excludeUserIds = const [],
    int maxRecommendations = 20,
    bool forceRefresh = false,
  }) async {
    try {
      AppLogger.logger.d('🔍 Getting ML recommendations for user: $arg');

      // Check if we already have data and don't need to refresh
      if (!forceRefresh && state.hasValue && state.value != null) {
        AppLogger.logger.d('📦 Using cached recommendations');
        return;
      }

      state = const AsyncLoading();

      // Get current user from auth provider
      final authState = ref.read(authStateProvider);
      if (!authState.hasValue || authState.value == null) {
        throw Exception('User not authenticated');
      }

      final userProfile = ref.read(userProfileProvider);
      if (!userProfile.hasValue || userProfile.value == null) {
        throw Exception('User profile not found');
      }

      final mlService = ref.read(mlMatchingServiceProvider);
      final recommendations = await mlService.getRecommendations(
        currentUser: userProfile.value!,
        excludeUserIds: excludeUserIds,
        maxRecommendations: maxRecommendations,
        includeAnalytics: true,
        useCache: !forceRefresh,
      );

      state = AsyncData(recommendations);

      AppLogger.logger.success(
          '✅ Loaded ${recommendations.recommendations.length} ML recommendations');
    } catch (error, stackTrace) {
      AppLogger.logger.e('❌ Error getting ML recommendations',
          error: error, stackTrace: stackTrace);
      state = AsyncError(error, stackTrace);
    }
  }

  /// Record a swipe and potentially update recommendations
  Future<void> recordSwipe({
    required String targetId,
    required SwipeDirection direction,
    String targetType = 'user',
  }) async {
    try {
      AppLogger.logger.d('👆 Recording swipe: $arg -> $targetId ($direction)');

      final mlService = ref.read(mlMatchingServiceProvider);
      final success = await mlService.recordSwipe(
        swiperId: arg,
        targetId: targetId,
        direction: direction,
        targetType: targetType,
      );

      if (success) {
        AppLogger.logger.d('✅ Swipe recorded successfully');

        // Update recommendations if we have them
        if (state.hasValue && state.value != null) {
          final currentRecommendations = state.value!;
          final updatedRecommendations = MLRecommendationResponse(
            userId: currentRecommendations.userId,
            recommendations: currentRecommendations.recommendations
                .where((rec) => rec.targetUserId != targetId)
                .toList(),
            generatedAt: currentRecommendations.generatedAt,
            modelVersion: currentRecommendations.modelVersion,
            analytics: currentRecommendations.analytics,
          );

          state = AsyncData(updatedRecommendations);
        }
      }
    } catch (error) {
      AppLogger.logger.e('❌ Error recording swipe', error: error);
      // Don't update state on swipe recording error
    }
  }

  /// Refresh recommendations
  Future<void> refresh() async {
    await getRecommendations(forceRefresh: true);
  }

  /// Get similarity score between current user and target
  Future<double> getSimilarityScore(String targetUserId) async {
    try {
      final mlService = ref.read(mlMatchingServiceProvider);
      return await mlService.getUserSimilarityScore(
        userId1: arg,
        userId2: targetUserId,
      );
    } catch (error) {
      AppLogger.logger.e('❌ Error getting similarity score', error: error);
      return 0.0;
    }
  }
}

/// ML Backend Status Notifier
class MLBackendStatusNotifier extends AsyncNotifier<MLBackendStatus> {
  @override
  Future<MLBackendStatus> build() async {
    return _checkBackendStatus();
  }

  Future<MLBackendStatus> _checkBackendStatus() async {
    try {
      AppLogger.logger.d('🏥 Checking ML backend status');

      final mlService = ref.read(mlMatchingServiceProvider);
      final status = await mlService.getBackendStatus();

      AppLogger.logger.d('✅ ML backend status: ${status.status}');
      return status;
    } catch (error, stackTrace) {
      AppLogger.logger.e('❌ Error checking ML backend status',
          error: error, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Refresh backend status
  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final status = await _checkBackendStatus();
      state = AsyncData(status);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  /// Check if backend is healthy
  bool get isBackendHealthy {
    if (!state.hasValue || state.value == null) return false;
    return state.value!.isHealthy;
  }
}

/// ML Analytics Stats Notifier
class MLAnalyticsStatsNotifier extends AsyncNotifier<MLAnalyticsStats> {
  @override
  Future<MLAnalyticsStats> build() async {
    return _getAnalyticsStats();
  }

  Future<MLAnalyticsStats> _getAnalyticsStats() async {
    try {
      AppLogger.logger.d('📊 Getting ML analytics stats');

      final mlService = ref.read(mlMatchingServiceProvider);
      final stats = await mlService.getAnalyticsStats();

      AppLogger.logger.d('✅ ML analytics stats loaded');
      return stats;
    } catch (error, stackTrace) {
      AppLogger.logger.e('❌ Error getting ML analytics stats',
          error: error, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Refresh analytics stats
  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final stats = await _getAnalyticsStats();
      state = AsyncData(stats);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }
}

/// Helper provider to get recommendations for current authenticated user
final currentUserRecommendationsProvider =
    Provider<AsyncValue<MLRecommendationResponse?>>((ref) {
  final authState = ref.watch(authStateProvider);

  if (!authState.hasValue || authState.value == null) {
    return const AsyncData(null);
  }

  final userId = authState.value!.uid;
  return ref.watch(mlRecommendationsProvider(userId));
});

/// Provider to easily access ML service methods
final mlServiceActionsProvider = Provider<MLServiceActions>((ref) {
  return MLServiceActions(ref);
});

/// Actions class for ML service operations
class MLServiceActions {
  final Ref _ref;

  MLServiceActions(this._ref);

  /// Get recommendations for current user
  Future<void> getRecommendationsForCurrentUser({
    List<String> excludeUserIds = const [],
    int maxRecommendations = 20,
    bool forceRefresh = false,
  }) async {
    final authState = _ref.read(authStateProvider);
    if (!authState.hasValue || authState.value == null) {
      throw Exception('User not authenticated');
    }

    final userId = authState.value!.uid;
    final notifier = _ref.read(mlRecommendationsProvider(userId).notifier);

    await notifier.getRecommendations(
      excludeUserIds: excludeUserIds,
      maxRecommendations: maxRecommendations,
      forceRefresh: forceRefresh,
    );
  }

  /// Record swipe for current user
  Future<void> recordSwipeForCurrentUser({
    required String targetId,
    required SwipeDirection direction,
    String targetType = 'user',
  }) async {
    final authState = _ref.read(authStateProvider);
    if (!authState.hasValue || authState.value == null) {
      throw Exception('User not authenticated');
    }

    final userId = authState.value!.uid;
    final notifier = _ref.read(mlRecommendationsProvider(userId).notifier);

    await notifier.recordSwipe(
      targetId: targetId,
      direction: direction,
      targetType: targetType,
    );
  }

  /// Update user profile in ML backend
  Future<bool> updateUserProfileInMLBackend() async {
    final userProfile = _ref.read(userProfileProvider);
    if (!userProfile.hasValue || userProfile.value == null) {
      throw Exception('User profile not found');
    }

    final mlService = _ref.read(mlMatchingServiceProvider);
    return await mlService.updateUserProfile(userProfile.value!);
  }

  /// Check if ML backend is healthy
  bool get isMLBackendHealthy {
    final statusNotifier = _ref.read(mlBackendStatusProvider.notifier);
    return statusNotifier.isBackendHealthy;
  }

  /// Refresh all ML data
  Future<void> refreshAllMLData() async {
    final futures = <Future>[];

    // Refresh backend status
    futures.add(_ref.read(mlBackendStatusProvider.notifier).refresh());

    // Refresh analytics stats
    futures.add(_ref.read(mlAnalyticsStatsProvider.notifier).refresh());

    // Refresh recommendations for current user
    final authState = _ref.read(authStateProvider);
    if (authState.hasValue && authState.value != null) {
      final userId = authState.value!.uid;
      futures
          .add(_ref.read(mlRecommendationsProvider(userId).notifier).refresh());
    }

    await Future.wait(futures);
  }
}

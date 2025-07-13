import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ml_matching_service.dart';
import '../models/models.dart';
import '../core/utils/logger.dart';

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

// ML Matching Service Provider
final mlMatchingServiceProvider = Provider<MLMatchingService>((ref) {
  return MLMatchingService.instance;
});

// ML Recommendations Provider
final mlRecommendationsProvider = StateNotifierProvider<
    MLRecommendationsNotifier, AsyncValue<Map<String, dynamic>?>>((ref) {
  return MLRecommendationsNotifier(ref);
});

// ML Backend Status Provider
final mlBackendStatusProvider = StateNotifierProvider<MLBackendStatusNotifier,
    AsyncValue<Map<String, dynamic>?>>((ref) {
  return MLBackendStatusNotifier(ref);
});

// ML Analytics Stats Provider
final mlAnalyticsStatsProvider = StateNotifierProvider<MLAnalyticsStatsNotifier,
    AsyncValue<Map<String, dynamic>?>>((ref) {
  return MLAnalyticsStatsNotifier(ref);
});

// ML Recommendations Notifier
class MLRecommendationsNotifier
    extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  final Ref _ref;

  MLRecommendationsNotifier(this._ref) : super(const AsyncValue.loading());

  Future<void> getRecommendations({
    required UserModel currentUser,
    List<String> excludeUserIds = const [],
    int maxRecommendations = 20,
    bool includeAnalytics = true,
    bool useCache = true,
  }) async {
    try {
      state = const AsyncValue.loading();

      final mlService = _ref.read(mlMatchingServiceProvider);
      final recommendations = await mlService.getRecommendations(
        currentUser: currentUser,
        excludeUserIds: excludeUserIds,
        maxRecommendations: maxRecommendations,
        includeAnalytics: includeAnalytics,
        useCache: useCache,
      );

      state = AsyncValue.data(recommendations);
      AppLogger.logger.success('✅ ML recommendations loaded successfully');
    } catch (error, stackTrace) {
      AppLogger.logger.e('❌ Failed to get ML recommendations',
          error: error, stackTrace: stackTrace);
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> recordSwipe({
    required String swiperId,
    required String targetId,
    required SwipeDirection direction,
    String targetType = 'user',
  }) async {
    try {
      final mlService = _ref.read(mlMatchingServiceProvider);
      await mlService.recordSwipe(
        swiperId: swiperId,
        targetId: targetId,
        direction: direction,
        targetType: targetType,
      );
      AppLogger.logger.success('✅ Swipe recorded successfully');
    } catch (error, stackTrace) {
      AppLogger.logger
          .e('❌ Failed to record swipe', error: error, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> updateUserProfile(UserModel user) async {
    try {
      final mlService = _ref.read(mlMatchingServiceProvider);
      await mlService.updateUserProfile(user);
      AppLogger.logger.success('✅ User profile updated in ML backend');
    } catch (error, stackTrace) {
      AppLogger.logger.e('❌ Failed to update user profile',
          error: error, stackTrace: stackTrace);
      rethrow;
    }
  }
}

// ML Backend Status Notifier
class MLBackendStatusNotifier
    extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  final Ref _ref;

  MLBackendStatusNotifier(this._ref) : super(const AsyncValue.loading());

  Future<void> getBackendStatus() async {
    try {
      state = const AsyncValue.loading();

      final mlService = _ref.read(mlMatchingServiceProvider);
      final status = await mlService.getBackendStatus();

      state = AsyncValue.data(status);
      AppLogger.logger.success('✅ ML backend status loaded');
    } catch (error, stackTrace) {
      AppLogger.logger.e('❌ Failed to get ML backend status',
          error: error, stackTrace: stackTrace);
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// ML Analytics Stats Notifier
class MLAnalyticsStatsNotifier
    extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  final Ref _ref;

  MLAnalyticsStatsNotifier(this._ref) : super(const AsyncValue.loading());

  Future<void> getAnalyticsStats() async {
    try {
      state = const AsyncValue.loading();

      final mlService = _ref.read(mlMatchingServiceProvider);
      final stats = await mlService.getAnalyticsStats();

      state = AsyncValue.data(stats);
      AppLogger.logger.success('✅ ML analytics stats loaded');
    } catch (error, stackTrace) {
      AppLogger.logger.e('❌ Failed to get ML analytics stats',
          error: error, stackTrace: stackTrace);
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

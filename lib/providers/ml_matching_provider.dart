import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/logger.dart';
import '../models/models.dart' as models;
import '../services/ml_matching_service.dart';

/// Swipe direction enum for ML matching
enum SwipeDirection {
  left,
  right;

  /// Convert boolean like to SwipeDirection
  static SwipeDirection fromLike(bool isLike) => isLike ? SwipeDirection.right : SwipeDirection.left;

  /// Convert SwipeDirection to boolean like
  bool get isLike => this == SwipeDirection.right;
}

// ML Matching Service Provider
final mlMatchingServiceProvider = Provider<MLMatchingService>((ref) => MLMatchingService.instance);

// ML Recommendations Provider
final mlRecommendationsProvider = StateNotifierProvider<
    MLRecommendationsNotifier, AsyncValue<Map<String, dynamic>?>>(MLRecommendationsNotifier.new);

// ML Backend Status Provider
final mlBackendStatusProvider = StateNotifierProvider<MLBackendStatusNotifier,
    AsyncValue<Map<String, dynamic>?>>(MLBackendStatusNotifier.new);

// ML Analytics Stats Provider
final mlAnalyticsStatsProvider = StateNotifierProvider<MLAnalyticsStatsNotifier,
    AsyncValue<Map<String, dynamic>?>>(MLAnalyticsStatsNotifier.new);

// ML Recommendations Notifier
class MLRecommendationsNotifier
    extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {

  MLRecommendationsNotifier(this._ref) : super(const AsyncValue.loading());
  final Ref _ref;

  /// Get ML recommendations
  Future<List<models.UserModel>> getRecommendations({
    required models.UserModel currentUser,
    List<String> excludeUserIds = const [],
    int maxRecommendations = 20,
  }) async {
    try {
      state = const AsyncValue.loading();

      final mlService = _ref.read(mlMatchingServiceProvider);
      final response = await mlService.getRecommendations(
        currentUser: currentUser,
        excludeUserIds: excludeUserIds,
        maxRecommendations: maxRecommendations,
      );

      final recommendations = response['recommendations'] as List<dynamic>? ?? [];
      final userModels = recommendations
          .map((rec) => models.UserModel.fromJson(rec as Map<String, dynamic>))
          .toList();

      state = AsyncValue.data(response);
      return userModels;
    } on Exception catch (e, stackTrace) {
      AppLogger.logger.e('Error getting ML recommendations', error: e, stackTrace: stackTrace);
      state = AsyncValue.error(e, stackTrace);
      return [];
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

  Future<void> updateUserProfile(models.UserModel user) async {
    try {
      final mlService = _ref.read(mlMatchingServiceProvider);
      await mlService.updateUserProfile(user);
      AppLogger.logger.success('✅ User profile updated in ML backend');
    } catch (error, stackTrace) {
      AppLogger.logger.e('❌ Failed to update user profile',
          error: error, stackTrace: stackTrace,);
      rethrow;
    }
  }
}

// ML Backend Status Notifier
class MLBackendStatusNotifier
    extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {

  MLBackendStatusNotifier(this._ref) : super(const AsyncValue.loading());
  final Ref _ref;

  Future<void> getBackendStatus() async {
    try {
      state = const AsyncValue.loading();

      final mlService = _ref.read(mlMatchingServiceProvider);
      final status = await mlService.getBackendStatus();

      state = AsyncValue.data(status);
      AppLogger.logger.success('✅ ML backend status loaded');
    } catch (error, stackTrace) {
      AppLogger.logger.e('❌ Failed to get ML backend status',
          error: error, stackTrace: stackTrace,);
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// ML Analytics Stats Notifier
class MLAnalyticsStatsNotifier
    extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {

  MLAnalyticsStatsNotifier(this._ref) : super(const AsyncValue.loading());
  final Ref _ref;

  Future<void> getAnalyticsStats() async {
    try {
      state = const AsyncValue.loading();

      final mlService = _ref.read(mlMatchingServiceProvider);
      final stats = await mlService.getAnalyticsStats();

      state = AsyncValue.data(stats);
      AppLogger.logger.success('✅ ML analytics stats loaded');
    } catch (error, stackTrace) {
      AppLogger.logger.e('❌ Failed to get ML analytics stats',
          error: error, stackTrace: stackTrace,);
      state = AsyncValue.error(error, stackTrace);
    }
  }
}


import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ml_matching_service.dart';
import '../models/models.dart';
import '../core/utils/logger.dart';

/// Provider for ML matching service
final mlMatchingServiceProvider = Provider<MLMatchingService>((ref) {
  return MLMatchingService();
});

/// Provider for ML recommendations
final mlRecommendationsProvider = StateNotifierProvider<
    MLRecommendationsNotifier, AsyncValue<List<MLRecommendation>>>((ref) {
  final mlService = ref.read(mlMatchingServiceProvider);
  return MLRecommendationsNotifier(mlService);
});

/// Provider for ML analytics
final mlAnalyticsProvider = FutureProvider<MLAnalytics?>((ref) async {
  final mlService = ref.read(mlMatchingServiceProvider);
  return await mlService.getAnalytics();
});

/// Provider for checking ML backend health
final mlHealthProvider = FutureProvider<bool>((ref) async {
  final mlService = ref.read(mlMatchingServiceProvider);
  return await mlService.isHealthy();
});

/// State notifier for managing ML recommendations
class MLRecommendationsNotifier
    extends StateNotifier<AsyncValue<List<MLRecommendation>>> {
  final MLMatchingService _mlService;
  List<String> _excludedUserIds = [];

  MLRecommendationsNotifier(this._mlService)
      : super(const AsyncValue.loading());

  /// Fetch ML-powered recommendations for a user
  Future<void> fetchRecommendations(UserModel user) async {
    try {
      state = const AsyncValue.loading();
      AppLogger.logger.d('🤖 Fetching ML recommendations for: ${user.name}');

      // Update user profile in ML backend first
      await _mlService.updateUserProfile(user);

      // Get recommendations
      final recommendations = await _mlService.getRecommendations(
        user: user,
        excludeUserIds: _excludedUserIds,
        maxRecommendations: 20,
      );

      state = AsyncValue.data(recommendations);
      AppLogger.logger.success(
          '✅ ML recommendations loaded: ${recommendations.length} matches');
    } catch (error, stackTrace) {
      AppLogger.logger.e('❌ Failed to fetch ML recommendations',
          error: error, stackTrace: stackTrace);
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Record a swipe and update recommendations
  Future<void> recordSwipeAndUpdate(
      SwipeModel swipe, UserModel currentUser) async {
    try {
      // Record swipe for ML training
      await _mlService.recordSwipe(swipe);

      // Add to excluded list
      _excludedUserIds.add(swipe.targetId);

      // If we're running low on recommendations, fetch more
      final currentRecommendations = state.value ?? [];
      if (currentRecommendations.length <= 3) {
        AppLogger.logger.d('🔄 Low on recommendations, fetching more...');
        await fetchRecommendations(currentUser);
      } else {
        // Remove the swiped user from current recommendations
        final updatedRecommendations = currentRecommendations
            .where((rec) => rec.uid != swipe.targetId)
            .toList();
        state = AsyncValue.data(updatedRecommendations);
      }
    } catch (error, stackTrace) {
      AppLogger.logger.e(
        '❌ Failed to record swipe and update recommendations',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Refresh recommendations (clear cache and fetch new)
  Future<void> refresh(UserModel user) async {
    _excludedUserIds.clear();
    await fetchRecommendations(user);
  }

  /// Get next recommendation from the list
  MLRecommendation? getNextRecommendation() {
    final recommendations = state.value;
    if (recommendations == null || recommendations.isEmpty) {
      return null;
    }
    return recommendations.first;
  }

  /// Check if there are more recommendations available
  bool get hasMoreRecommendations {
    final recommendations = state.value;
    return recommendations != null && recommendations.isNotEmpty;
  }

  /// Get recommendation by user ID
  MLRecommendation? getRecommendationByUserId(String userId) {
    final recommendations = state.value;
    if (recommendations == null) return null;

    try {
      return recommendations.firstWhere((rec) => rec.uid == userId);
    } catch (e) {
      return null;
    }
  }
}

/// Extension for easy access to ML recommendations
extension MLRecommendationsRef on WidgetRef {
  /// Watch ML recommendations
  AsyncValue<List<MLRecommendation>> get mlRecommendations =>
      watch(mlRecommendationsProvider);

  /// Read ML recommendations notifier
  MLRecommendationsNotifier get mlRecommendationsNotifier =>
      read(mlRecommendationsProvider.notifier);

  /// Check if ML backend is healthy
  AsyncValue<bool> get mlHealth => watch(mlHealthProvider);

  /// Get ML analytics
  AsyncValue<MLAnalytics?> get mlAnalytics => watch(mlAnalyticsProvider);
}

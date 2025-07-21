import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';

// Simple stub swipe provider to unblock build
final swipeProvider =
    StateNotifierProvider<SwipeNotifier, AsyncValue<List<UserModel>>>((ref) {
  return SwipeNotifier();
});

class SwipeState {
  final List<UserModel> recommendations;
  final bool isLoading;
  final String? error;

  SwipeState({
    this.recommendations = const [],
    this.isLoading = false,
    this.error,
  });

  SwipeState copyWith({
    List<UserModel>? recommendations,
    bool? isLoading,
    String? error,
  }) {
    return SwipeState(
      recommendations: recommendations ?? this.recommendations,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class SwipeNotifier extends StateNotifier<AsyncValue<List<UserModel>>> {
  SwipeNotifier() : super(const AsyncValue.data([]));

  Future<void> loadRecommendations(String userId) async {
    state = const AsyncValue.loading();

    try {
      // Integrate with ML backend or user service to get real recommendations
      await Future.delayed(const Duration(milliseconds: 500));

      // For now, return empty list until ML backend is fully integrated
      state = const AsyncValue.data([]);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> recordSwipe(String userId, bool isLike) async {
    try {
      // Record swipe with analytics or ML service
      await Future.delayed(const Duration(milliseconds: 100));

      // Implementation will be added when swipe recording API is ready
    } catch (error) {
      // Handle error silently for now
    }
  }
}

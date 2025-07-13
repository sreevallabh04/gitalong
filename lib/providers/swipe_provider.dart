import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';

// Simple stub swipe provider to unblock build
final swipeProvider = StateNotifierProvider<SwipeNotifier, AsyncValue<List<UserModel>>>((ref) {
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
    // TODO: Implement actual recommendation loading
    await Future.delayed(const Duration(milliseconds: 500));
    state = const AsyncValue.data([]);
  }

  Future<void> recordSwipe(String userId, bool isLike) async {
    // TODO: Implement actual swipe recording
    await Future.delayed(const Duration(milliseconds: 100));
  }
}

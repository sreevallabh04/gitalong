import '../entities/swipe_entity.dart';
import '../entities/match_entity.dart';

/// Swipe repository interface
abstract class SwipeRepository {
  /// Record a swipe action
  Future<void> swipeUser({
    required String swipedUserId,
    required SwipeAction action,
  });

  /// Check if swipe resulted in a match
  Future<MatchEntity?> checkForMatch(String swipedUserId);

  /// Get swipe history
  Future<List<SwipeEntity>> getSwipeHistory({int limit = 50, String? cursor});

  /// Undo last swipe (if within time limit)
  Future<void> undoLastSwipe();

  /// Get already swiped user IDs (to exclude from recommendations)
  Future<List<String>> getSwipedUserIds();
}

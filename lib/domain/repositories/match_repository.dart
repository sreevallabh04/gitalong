import '../entities/match_entity.dart';

/// Repository for match-related operations
abstract class MatchRepository {
  /// Get matches for current user
  Future<List<MatchEntity>> getMatches({int limit = 20});

  /// Get match by ID
  Future<MatchEntity?> getMatchById(String matchId);

  /// Create a new match
  Future<MatchEntity> createMatch(MatchEntity match);

  /// Update match status
  Future<MatchEntity> updateMatchStatus(String matchId, MatchStatus status);

  /// Delete match
  Future<void> deleteMatch(String matchId);

  /// Record a swipe action
  Future<SwipeActionEntity> recordSwipe(SwipeActionEntity swipe);

  /// Get swipe history for user
  Future<List<SwipeActionEntity>> getSwipeHistory(
    String userId, {
    int limit = 50,
  });

  /// Get potential matches (users/projects to swipe on)
  Future<List<dynamic>> getPotentialMatches(String userId, {int limit = 10});

  /// Check if users have matched
  Future<bool> hasMatched(String userId1, String userId2);

  /// Get match statistics
  Future<MatchStats> getMatchStats(String userId);

  /// Stream of new matches
  Stream<MatchEntity> getNewMatchesStream();

  /// Stream of match updates
  Stream<MatchEntity> getMatchUpdates(String matchId);
}

/// Statistics for matches
class MatchStats {
  /// Total number of matches
  final int totalMatches;

  /// Total number of likes given
  final int totalLikes;

  /// Total number of passes given
  final int totalPasses;

  /// Total number of super likes given
  final int totalSuperLikes;

  /// Match rate percentage
  final double matchRate;

  /// Number of matches this week
  final int thisWeekMatches;

  /// Creates match statistics
  const MatchStats({
    required this.totalMatches,
    required this.totalLikes,
    required this.totalPasses,
    required this.totalSuperLikes,
    required this.matchRate,
    required this.thisWeekMatches,
  });
}

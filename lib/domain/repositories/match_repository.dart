import '../entities/match_entity.dart';

/// Match repository interface
abstract class MatchRepository {
  /// Get all matches for current user
  Future<List<MatchEntity>> getMatches({int limit = 50, String? cursor});

  /// Get match by ID
  Future<MatchEntity> getMatchById(String matchId);

  /// Unmatch user
  Future<void> unmatch(String matchId);

  /// Check if users are matched
  Future<bool> isMatched(String userId);
}

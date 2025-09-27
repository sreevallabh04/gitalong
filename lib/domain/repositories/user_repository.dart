import '../entities/user_entity.dart';

/// Repository for user-related operations
abstract class UserRepository {
  /// Get user by ID
  Future<UserEntity?> getUserById(String userId);

  /// Get user by username
  Future<UserEntity?> getUserByUsername(String username);

  /// Search users by query
  Future<List<UserEntity>> searchUsers(String query, {int limit = 20});

  /// Get nearby users
  Future<List<UserEntity>> getNearbyUsers(
    double latitude,
    double longitude,
    int radiusKm,
  );

  /// Get recommended users for current user
  Future<List<UserEntity>> getRecommendedUsers(String userId, {int limit = 20});

  /// Get user's followers
  Future<List<UserEntity>> getFollowers(String userId, {int limit = 20});

  /// Get user's following
  Future<List<UserEntity>> getFollowing(String userId, {int limit = 20});

  /// Follow a user
  Future<void> followUser(String userId);

  /// Unfollow a user
  Future<void> unfollowUser(String userId);

  /// Check if user is following another user
  Future<bool> isFollowing(String userId);

  /// Update user preferences
  Future<void> updatePreferences(UserPreferences preferences);

  /// Get user's GitHub activity
  Future<Map<String, dynamic>> getGitHubActivity(String username);

  /// Get user's contribution graph
  Future<List<ContributionDay>> getContributionGraph(String username);

  /// Stream of user updates
  Stream<UserEntity> getUserUpdates(String userId);
}

/// Represents a contribution day
class ContributionDay {
  /// Date of the contribution
  final DateTime date;

  /// Number of contributions on this date
  final int count;

  /// Activity level (0-4)
  final int level;

  /// Creates a contribution day
  const ContributionDay({
    required this.date,
    required this.count,
    required this.level,
  });
}

import '../entities/user_entity.dart';

/// User repository interface
abstract class UserRepository {
  /// Get user by ID
  Future<UserEntity> getUserById(String userId);

  /// Get user by username
  Future<UserEntity> getUserByUsername(String username);

  /// Get current user profile
  Future<UserEntity> getCurrentUserProfile();

  /// Update user profile
  Future<UserEntity> updateUserProfile(UserEntity user);

  /// Get recommended users for swiping
  Future<List<UserEntity>> getRecommendedUsers({
    int limit = 20,
    String? cursor,
  });

  /// Search users
  Future<List<UserEntity>> searchUsers({
    required String query,
    int limit = 20,
    String? cursor,
  });

  /// Get user's GitHub stats
  Future<Map<String, dynamic>> getUserGitHubStats(String username);
}

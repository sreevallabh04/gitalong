import '../entities/user_entity.dart';

/// Repository for authentication operations
abstract class AuthRepository {
  /// Get current authenticated user
  Future<UserEntity?> getCurrentUser();

  /// Sign in with GitHub OAuth
  Future<UserEntity> signInWithGitHub();

  /// Sign in with Apple
  Future<UserEntity> signInWithApple();

  /// Sign out current user
  Future<void> signOut();

  /// Check if user is authenticated
  Future<bool> isAuthenticated();

  /// Update user profile
  Future<UserEntity> updateProfile(UserEntity user);

  /// Delete user account
  Future<void> deleteAccount();

  /// Refresh user token
  Future<String> refreshToken();

  /// Stream of authentication state changes
  Stream<UserEntity?> get authStateChanges;
}

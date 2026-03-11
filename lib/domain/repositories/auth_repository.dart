import '../entities/user_entity.dart';

/// Authentication repository interface
abstract class AuthRepository {
  /// Sign in with GitHub
  Future<UserEntity> signInWithGitHub();

  /// Sign in with Google
  Future<UserEntity> signInWithGoogle();

  /// Sign in with Apple
  Future<UserEntity> signInWithApple();

  /// Sign out
  Future<void> signOut();

  /// Get current user
  Future<UserEntity?> getCurrentUser();

  /// Check if user is authenticated
  Future<bool> isAuthenticated();

  /// Delete account
  Future<void> deleteAccount();
}

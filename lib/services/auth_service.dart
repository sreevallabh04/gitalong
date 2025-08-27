import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../models/user_model.dart';
import '../models/user_roles.dart' as roles;
import '../core/utils/logger.dart';

/// Custom exception for authentication errors
class AuthException implements Exception {
  final String message;
  final String? code;

  const AuthException(this.message, {this.code});

  @override
  String toString() => 'AuthException($code): $message';
}

/// Core authentication service for Firebase Auth integration
class AuthService {
  // Firebase instances
  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  // Current user getters
  User? get currentUser => _auth.currentUser;
  bool get isAuthenticated => _auth.currentUser != null;
  // Auth state stream with error handling
  Stream<User?> get authStateChanges =>
      _auth.authStateChanges().handleError((error) {
        AppLogger.logger.e('Auth state change error: $error');
        if (error.toString().contains('credential is no longer valid')) {
          // Force sign out on invalid credentials
          signOut();
        }
      });

  // Token refresh method
  Future<bool> refreshUserToken() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      AppLogger.logger.d('🔄 Refreshing user token...');
      await user.getIdToken(true); // Force refresh
      AppLogger.logger.success('✅ Token refreshed successfully');
      return true;
    } catch (e) {
      AppLogger.logger.e('❌ Failed to refresh token: $e');
      if (e.toString().contains('credential is no longer valid')) {
        await signOut();
      }
      return false;
    }
  }

  // Check and handle auth errors
  Future<void> handleAuthError(dynamic error) async {
    if (error.toString().contains('credential is no longer valid') ||
        error.toString().contains('FirebaseAuthInvalidUserException')) {
      AppLogger.logger.w('🔒 Invalid credentials detected, signing out user');
      await signOut();
    }
  }

  // Authentication methods
  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      AppLogger.logger.auth('🔐 Signing in with email: $email');
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      AppLogger.logger.auth('✅ Email sign-in successful');
      return result;
    } on FirebaseAuthException catch (e) {
      AppLogger.logger.e('❌ Email sign-in failed', error: e);
      throw AuthException(_getErrorMessage(e), code: e.code);
    }
  }

  Future<void> signOut() async {
    try {
      AppLogger.logger.auth('👋 Signing out...');
      await _auth.signOut();
      AppLogger.logger.auth('✅ Sign out successful');
    } catch (e) {
      AppLogger.logger.e('❌ Sign out failed', error: e);
      rethrow;
    }
  }

  Future<UserCredential> createAccount(
      {required String email,
      required String password,
      String? displayName}) async {
    try {
      AppLogger.logger.auth('👤 Creating account for: $email');

      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name if provided
      if (displayName != null) {
        await result.user?.updateDisplayName(displayName);
      }

      AppLogger.logger.auth('✅ Account created successfully');
      return result;
    } on FirebaseAuthException catch (e) {
      AppLogger.logger.e('❌ Account creation failed', error: e);
      throw AuthException(_getErrorMessage(e), code: e.code);
    }
  }

  Future<UserCredential> signInWithApple() async {
    try {
      AppLogger.logger.auth('🍎 Signing in with Apple...');

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      final result = await _auth.signInWithCredential(oauthCredential);
      AppLogger.logger.auth('✅ Apple sign-in successful');
      return result;
    } on FirebaseAuthException catch (e) {
      AppLogger.logger.e('❌ Apple sign-in failed', error: e);
      throw AuthException(_getErrorMessage(e), code: e.code);
    } catch (e) {
      AppLogger.logger.e('❌ Apple sign-in failed', error: e);
      throw AuthException('Apple sign-in failed: ${e.toString()}');
    }
  }

  Future<UserCredential> signInWithGitHubMobile() async {
    try {
      AppLogger.logger.auth('🐙 Starting mock GitHub sign-in...');

      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));

      // For mock implementation, we'll create a real Firebase user
      // This simulates what would happen with actual GitHub OAuth
      const mockEmail = 'mock.github.user@example.com';
      final mockPassword = 'mock_password_${DateTime.now().millisecondsSinceEpoch}';

      // Create a temporary account for the mock GitHub user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: mockEmail,
        password: mockPassword,
      );

      if (userCredential.user != null) {
        // Update the user profile to simulate GitHub data
        await userCredential.user!.updateDisplayName('Mock GitHub User');
        await userCredential.user!.updatePhotoURL('https://avatars.githubusercontent.com/u/mock');
        
        // Mark email as verified (GitHub emails are typically verified)
        // Note: In a real implementation, this would be handled by Firebase Auth
        AppLogger.logger.auth('✅ Mock GitHub user created and configured');
      }

      AppLogger.logger.auth('✅ Mock GitHub sign-in successful');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      AppLogger.logger.e('❌ Mock GitHub sign-in failed', error: e);
      throw AuthException(_getErrorMessage(e), code: e.code);
    } catch (e) {
      AppLogger.logger.e('❌ Mock GitHub sign-in failed', error: e);
      throw AuthException('Mock GitHub sign-in failed: ${e.toString()}');
    }
  }

  Future<UserModel?> getCurrentUserProfile() async {
    try {
      if (!isAuthenticated) return null;

      final doc =
          await _firestore.collection('users').doc(currentUser!.uid).get();

      if (!doc.exists) return null;

      return UserModel.fromJson(doc.data()!);
    } catch (e) {
      AppLogger.logger.e('❌ Failed to get user profile', error: e);
      return null;
    }
  }

  Future<UserModel> upsertUserProfile({
    required String name,
    required roles.UserRole role,
    String? bio,
    String? githubUrl,
    List<String>? skills,
  }) async {
    try {
      if (!isAuthenticated) {
        throw const AuthException('User not authenticated',
            code: 'not-authenticated');
      }

      final user = currentUser!;
      final userModel = UserModel(
        uid: user.uid,
        email: user.email!,
        name: name,
        displayName: name,
        role: role,
        bio: bio,
        githubUrl: githubUrl,
        skills: skills ?? [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isEmailVerified: user.emailVerified,
      );

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userModel.toJson(), SetOptions(merge: true));

      AppLogger.logger.auth('✅ User profile upserted successfully');
      return userModel;
    } catch (e) {
      AppLogger.logger.e('❌ Failed to upsert user profile', error: e);
      rethrow;
    }
  }

  Future<void> updateUserRole(String userId, String newRole) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({'role': newRole});

      AppLogger.logger.auth('✅ User role updated');
    } catch (e) {
      AppLogger.logger.e('❌ Failed to update user role', error: e);
      rethrow;
    }
  }

  Future<void> reloadUser() async {
    try {
      if (currentUser != null) {
        await currentUser!.reload();
        AppLogger.logger.auth('✅ User reloaded successfully');
      }
    } catch (e) {
      AppLogger.logger.e('❌ Failed to reload user', error: e);
      rethrow;
    }
  }

  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return e.message ?? 'An error occurred during authentication.';
    }
  }
}

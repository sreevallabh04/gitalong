import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
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
  Stream<User?> get authStateChanges => _auth.authStateChanges();

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
    required UserRole role,
    String? bio,
    String? githubUrl,
    List<String>? skills,
  }) async {
    try {
      if (!isAuthenticated) {
        throw AuthException('User not authenticated',
            code: 'not-authenticated');
      }

      final user = currentUser!;
      final userModel = UserModel(
        id: user.uid,
        email: user.email!,
        name: name,
        displayName: name,
        role: role,
        bio: bio,
        githubUrl: githubUrl,
        skills: skills ?? [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
        emailVerified: user.emailVerified,
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

/// Provider for the auth service
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

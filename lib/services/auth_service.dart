import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../config/firebase_config.dart';
import '../models/models.dart';
import '../core/utils/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

class AuthService {
  // Lazy-loaded Firebase instances to prevent early initialization
  FirebaseAuth get _auth => FirebaseConfig.auth;
  FirebaseFirestore get _firestore => FirebaseConfig.firestore;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    // Add client ID for better compatibility
    serverClientId:
        '267802124592-tv5mnvog8sblshvnarf0c78ujf4pjbq7.apps.googleusercontent.com',
  );

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  /// Sign in with email and password with comprehensive error handling
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // 1. CREDENTIAL FORMAT SANITY - Trim whitespace
      final cleanEmail = email.trim();
      final cleanPassword = password.trim();

      AppLogger.logger.auth('🔐 Attempting email sign-in for: $cleanEmail');

      // 2. Basic validation
      if (cleanEmail.isEmpty) {
        throw const FormatException('Email cannot be empty');
      }
      if (cleanPassword.isEmpty) {
        throw const FormatException('Password cannot be empty');
      }
      if (!_isValidEmail(cleanEmail)) {
        throw const FormatException('Invalid email format');
      }

      // 3. Firebase sign-in with proper error handling
      final credential = await _auth.signInWithEmailAndPassword(
        email: cleanEmail,
        password: cleanPassword,
      );

      AppLogger.logger.auth('✅ Email sign-in successful for: $cleanEmail');
      return credential;
    } on FirebaseAuthException catch (e) {
      AppLogger.logger.e(
        '❌ Firebase Auth Error during email sign-in',
        error: e,
        stackTrace: StackTrace.current,
      );

      // 4. SPECIFIC ERROR HANDLING for each Firebase error code
      switch (e.code) {
        case 'user-not-found':
          throw AuthException(
            'No account found with this email. Please sign up first.',
            code: e.code,
          );
        case 'wrong-password':
          throw AuthException(
            'Incorrect password. Please try again.',
            code: e.code,
          );
        case 'invalid-credential':
          throw AuthException(
            'Invalid email or password. Please check your credentials.',
            code: e.code,
          );
        case 'invalid-email':
          throw AuthException(
            'Invalid email format. Please enter a valid email.',
            code: e.code,
          );
        case 'user-disabled':
          throw AuthException(
            'This account has been disabled. Please contact support.',
            code: e.code,
          );
        case 'too-many-requests':
          throw AuthException(
            'Too many failed attempts. Please try again later.',
            code: e.code,
          );
        case 'operation-not-allowed':
          throw AuthException(
            'Email/password sign-in is not enabled. Please contact support.',
            code: e.code,
          );
        case 'network-request-failed':
          throw AuthException(
            'Network error. Please check your internet connection.',
            code: e.code,
          );
        default:
          throw AuthException(
            'Sign-in failed: ${e.message ?? 'Unknown error'}',
            code: e.code,
          );
      }
    } on FormatException catch (e) {
      AppLogger.logger.e('❌ Format validation error', error: e);
      throw AuthException(e.message, code: 'format-error');
    } catch (e, stackTrace) {
      AppLogger.logger.e(
        '❌ Unexpected error during email sign-in',
        error: e,
        stackTrace: stackTrace,
      );
      throw const AuthException(
        'An unexpected error occurred. Please try again.',
        code: 'unknown-error',
      );
    }
  }

  /// Create user with email and password with comprehensive error handling
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // 1. CREDENTIAL FORMAT SANITY - Trim whitespace
      final cleanEmail = email.trim();
      final cleanPassword = password.trim();

      AppLogger.logger.auth('🔐 Attempting email sign-up for: $cleanEmail');

      // 2. Basic validation
      if (cleanEmail.isEmpty) {
        throw const FormatException('Email cannot be empty');
      }
      if (cleanPassword.isEmpty) {
        throw const FormatException('Password cannot be empty');
      }
      if (!_isValidEmail(cleanEmail)) {
        throw const FormatException('Invalid email format');
      }
      if (cleanPassword.length < 6) {
        throw const FormatException('Password must be at least 6 characters');
      }

      // 3. Firebase sign-up with proper error handling
      final credential = await _auth.createUserWithEmailAndPassword(
        email: cleanEmail,
        password: cleanPassword,
      );

      // 4. AUTOMATICALLY SEND EMAIL VERIFICATION
      if (credential.user != null && !credential.user!.emailVerified) {
        try {
          await credential.user!.sendEmailVerification();
          AppLogger.logger.auth('📧 Email verification sent to: $cleanEmail');
        } catch (e) {
          AppLogger.logger.w('⚠️ Failed to send verification email', error: e);
          // Don't throw error here - account creation was successful
        }
      }

      AppLogger.logger.auth('✅ Email sign-up successful for: $cleanEmail');
      return credential;
    } on FirebaseAuthException catch (e) {
      AppLogger.logger.e(
        '❌ Firebase Auth Error during email sign-up',
        error: e,
        stackTrace: StackTrace.current,
      );

      // 4. SPECIFIC ERROR HANDLING for each Firebase error code
      switch (e.code) {
        case 'email-already-in-use':
          throw AuthException(
            'An account already exists with this email. Please sign in instead.',
            code: e.code,
          );
        case 'invalid-email':
          throw AuthException(
            'Invalid email format. Please enter a valid email.',
            code: e.code,
          );
        case 'weak-password':
          throw AuthException(
            'Password is too weak. Please choose a stronger password.',
            code: e.code,
          );
        case 'operation-not-allowed':
          throw AuthException(
            'Email/password sign-up is not enabled. Please contact support.',
            code: e.code,
          );
        case 'network-request-failed':
          throw AuthException(
            'Network error. Please check your internet connection.',
            code: e.code,
          );
        default:
          throw AuthException(
            'Sign-up failed: ${e.message ?? 'Unknown error'}',
            code: e.code,
          );
      }
    } on FormatException catch (e) {
      AppLogger.logger.e('❌ Format validation error', error: e);
      throw AuthException(e.message, code: 'format-error');
    } catch (e, stackTrace) {
      AppLogger.logger.e(
        '❌ Unexpected error during email sign-up',
        error: e,
        stackTrace: stackTrace,
      );
      throw const AuthException(
        'An unexpected error occurred. Please try again.',
        code: 'unknown-error',
      );
    }
  }

  /// Google Sign In with comprehensive error handling
  Future<UserCredential> signInWithGoogle() async {
    try {
      AppLogger.logger.auth('🔐 Attempting Google sign-in');

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw const AuthException(
          'Google sign-in was cancelled by user',
          code: 'sign-in-cancelled',
        );
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        throw const AuthException(
          'Failed to obtain Google authentication tokens',
          code: 'token-error',
        );
      }

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);

      AppLogger.logger.auth('✅ Google sign-in successful');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      AppLogger.logger.e(
        '❌ Firebase Auth Error during Google sign-in',
        error: e,
        stackTrace: StackTrace.current,
      );

      switch (e.code) {
        case 'account-exists-with-different-credential':
          throw AuthException(
            'An account already exists with this email using a different sign-in method.',
            code: e.code,
          );
        case 'invalid-credential':
          throw AuthException(
            'Invalid Google credentials. Please try again.',
            code: e.code,
          );
        case 'operation-not-allowed':
          throw AuthException(
            'Google sign-in is not enabled. Please contact support.',
            code: e.code,
          );
        case 'user-disabled':
          throw AuthException(
            'This account has been disabled. Please contact support.',
            code: e.code,
          );
        case 'network-request-failed':
          throw AuthException(
            'Network error. Please check your internet connection.',
            code: e.code,
          );
        default:
          throw AuthException(
            'Google sign-in failed: ${e.message ?? 'Unknown error'}',
            code: e.code,
          );
      }
    } catch (e, stackTrace) {
      AppLogger.logger.e(
        '❌ Unexpected error during Google sign-in',
        error: e,
        stackTrace: stackTrace,
      );
      throw const AuthException(
        'Google sign-in failed. Please try again.',
        code: 'unknown-error',
      );
    }
  }

  /// Apple Sign In with comprehensive error handling
  Future<UserCredential> signInWithApple() async {
    try {
      AppLogger.logger.auth('🔐 Attempting Apple sign-in');

      // Request credential for the currently signed in Apple account
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Create an OAuthCredential from the credential returned by Apple
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in the user with Firebase
      final userCredential = await _auth.signInWithCredential(oauthCredential);

      AppLogger.logger.auth('✅ Apple sign-in successful');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      AppLogger.logger.e(
        '❌ Firebase Auth Error during Apple sign-in',
        error: e,
        stackTrace: StackTrace.current,
      );

      switch (e.code) {
        case 'account-exists-with-different-credential':
          throw AuthException(
            'An account already exists with this email using a different sign-in method.',
            code: e.code,
          );
        case 'invalid-credential':
          throw AuthException(
            'Invalid Apple credentials. Please try again.',
            code: e.code,
          );
        case 'operation-not-allowed':
          throw AuthException(
            'Apple sign-in is not enabled. Please contact support.',
            code: e.code,
          );
        case 'user-disabled':
          throw AuthException(
            'This account has been disabled. Please contact support.',
            code: e.code,
          );
        default:
          throw AuthException(
            'Apple sign-in failed: ${e.message ?? 'Unknown error'}',
            code: e.code,
          );
      }
    } catch (e, stackTrace) {
      AppLogger.logger.e(
        '❌ Unexpected error during Apple sign-in',
        error: e,
        stackTrace: stackTrace,
      );
      throw const AuthException(
        'Apple sign-in failed. Please try again.',
        code: 'unknown-error',
      );
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      final cleanEmail = email.trim();

      if (cleanEmail.isEmpty) {
        throw const FormatException('Email cannot be empty');
      }
      if (!_isValidEmail(cleanEmail)) {
        throw const FormatException('Invalid email format');
      }

      await _auth.sendPasswordResetEmail(email: cleanEmail);

      AppLogger.logger.auth('✅ Password reset email sent to: $cleanEmail');
    } on FirebaseAuthException catch (e) {
      AppLogger.logger.e('❌ Error sending password reset email', error: e);

      switch (e.code) {
        case 'user-not-found':
          throw AuthException(
            'No account found with this email.',
            code: e.code,
          );
        case 'invalid-email':
          throw AuthException(
            'Invalid email format.',
            code: e.code,
          );
        default:
          throw AuthException(
            'Failed to send reset email: ${e.message ?? 'Unknown error'}',
            code: e.code,
          );
      }
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      AppLogger.logger.auth('🔐 Signing out user');

      // Sign out from Google if signed in
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      // Sign out from Firebase
      await _auth.signOut();

      AppLogger.logger.auth('✅ User signed out successfully');
    } catch (e, stackTrace) {
      AppLogger.logger.e(
        '❌ Error during sign-out',
        error: e,
        stackTrace: stackTrace,
      );
      throw const AuthException(
        'Failed to sign out. Please try again.',
        code: 'sign-out-error',
      );
    }
  }

  /// Validate email format using RegExp
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  // Get current user profile
  Future<UserModel?> getCurrentUserProfile() async {
    if (!isAuthenticated) return null;

    try {
      final doc =
          await _firestore.collection('users').doc(currentUser!.uid).get();

      return doc.exists ? UserModel.fromJson(doc.data()!) : null;
    } catch (e) {
      throw AuthException(
        'Failed to get user profile: ${e.toString()}',
        code: 'profile-fetch-error',
      );
    }
  }

  // Create or update user profile
  Future<UserModel> upsertUserProfile({
    required String name,
    required UserRole role,
    String? bio,
    String? githubUrl,
    List<String> skills = const [],
  }) async {
    if (!isAuthenticated) {
      throw const AuthException(
        'User must be authenticated',
        code: 'not-authenticated',
      );
    }

    final user = currentUser!;
    final now = DateTime.now();

    final userData = {
      'id': user.uid,
      'email': user.email!,
      'name': name,
      'role': role.name,
      'avatar_url': user.photoURL ??
          'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=00F5FF&color=0A0A0F',
      'bio': bio,
      'github_url': githubUrl,
      'skills': skills,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    };

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userData, SetOptions(merge: true));

      return UserModel.fromJson(userData);
    } catch (e) {
      throw AuthException(
        'Failed to update user profile: ${e.toString()}',
        code: 'profile-update-error',
      );
    }
  }

  // Check if user profile exists
  Future<bool> hasUserProfile() async {
    if (!isAuthenticated) return false;

    try {
      final doc =
          await _firestore.collection('users').doc(currentUser!.uid).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  // Update user profile
  Future<UserModel> updateUserProfile({
    String? name,
    String? bio,
    String? githubUrl,
    List<String>? skills,
    String? avatarUrl,
  }) async {
    if (!isAuthenticated) {
      throw const AuthException(
        'User must be authenticated',
        code: 'not-authenticated',
      );
    }

    final updateData = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (name != null) updateData['name'] = name;
    if (bio != null) updateData['bio'] = bio;
    if (githubUrl != null) updateData['github_url'] = githubUrl;
    if (skills != null) updateData['skills'] = skills;
    if (avatarUrl != null) updateData['avatar_url'] = avatarUrl;

    try {
      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .update(updateData);

      final doc =
          await _firestore.collection('users').doc(currentUser!.uid).get();

      return UserModel.fromJson(doc.data()!);
    } catch (e) {
      throw AuthException(
        'Failed to update user profile: ${e.toString()}',
        code: 'profile-update-error',
      );
    }
  }

  // Delete user account
  Future<void> deleteAccount() async {
    if (!isAuthenticated) {
      throw const AuthException(
        'User must be authenticated',
        code: 'not-authenticated',
      );
    }

    try {
      // Delete user data from Firestore
      await _firestore.collection('users').doc(currentUser!.uid).delete();

      // Sign out from all providers
      await signOut();

      // Delete the user account
      await currentUser!.delete();
    } catch (e) {
      throw AuthException(
        'Failed to delete account: ${e.toString()}',
        code: 'account-deletion-error',
      );
    }
  }

  // Create user profile in Firestore
  Future<void> _createUserProfile({
    required User user,
    required String name,
    required UserRole role,
  }) async {
    final now = DateTime.now();
    final userData = {
      'id': user.uid,
      'email': user.email!,
      'name': name,
      'role': role.name,
      'avatar_url': user.photoURL ??
          'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=00F5FF&color=0A0A0F',
      'bio': null,
      'github_url': null,
      'skills': <String>[],
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    };

    await _firestore.collection('users').doc(user.uid).set(userData);
  }

  // Create or update user profile (for social logins)
  Future<void> _createOrUpdateUserProfile({
    required User user,
    required String name,
    required UserRole role,
  }) async {
    final docRef = _firestore.collection('users').doc(user.uid);
    final doc = await docRef.get();

    if (!doc.exists) {
      await _createUserProfile(user: user, name: name, role: role);
    } else {
      // Update last login time
      await docRef.update({
        'updated_at': DateTime.now().toIso8601String(),
      });
    }
  }

  /// Send email verification to current user
  Future<void> sendEmailVerification() async {
    final user = currentUser;
    if (user == null) {
      throw const AuthException(
        'No user is currently signed in.',
        code: 'no-current-user',
      );
    }

    if (user.emailVerified) {
      throw const AuthException(
        'Email is already verified.',
        code: 'already-verified',
      );
    }

    try {
      await user.sendEmailVerification();
      AppLogger.logger.auth('📧 Email verification sent to: ${user.email}');
    } on FirebaseAuthException catch (e) {
      AppLogger.logger.e('❌ Error sending email verification', error: e);

      switch (e.code) {
        case 'too-many-requests':
          throw const AuthException(
            'Too many verification emails sent. Please wait before requesting another.',
            code: 'too-many-requests',
          );
        case 'invalid-email':
          throw const AuthException(
            'Invalid email address.',
            code: 'invalid-email',
          );
        default:
          throw AuthException(
            'Failed to send verification email: ${e.message ?? 'Unknown error'}',
            code: e.code,
          );
      }
    } catch (e) {
      AppLogger.logger
          .e('❌ Unexpected error sending email verification', error: e);
      throw const AuthException(
        'Failed to send verification email. Please try again.',
        code: 'unknown-error',
      );
    }
  }

  /// Reload current user to check latest email verification status
  Future<void> reloadUser() async {
    final user = currentUser;
    if (user == null) {
      throw const AuthException(
        'No user is currently signed in.',
        code: 'no-current-user',
      );
    }

    try {
      await user.reload();
      AppLogger.logger.auth('🔄 User data reloaded for: ${user.email}');
    } catch (e) {
      AppLogger.logger.e('❌ Error reloading user', error: e);
      throw const AuthException(
        'Failed to refresh user data. Please try again.',
        code: 'reload-error',
      );
    }
  }

  /// Send verification email to a specific user by email (for existing users)
  Future<void> sendVerificationToUser(String email) async {
    if (!isAuthenticated) {
      throw const AuthException(
        'Must be authenticated to perform this action.',
        code: 'unauthenticated',
      );
    }

    try {
      final cleanEmail = email.trim();
      if (!_isValidEmail(cleanEmail)) {
        throw const AuthException(
          'Invalid email format.',
          code: 'invalid-email',
        );
      }

      // Check if user exists in Firestore
      final userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: cleanEmail)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        throw const AuthException(
          'User not found with this email.',
          code: 'user-not-found',
        );
      }

      // For existing users, we can't directly send verification emails through Admin SDK in client
      // We'll create a notification in Firestore that triggers a Cloud Function
      await _firestore.collection('email_notifications').add({
        'email': cleanEmail,
        'type': 'verification_reminder',
        'message': 'Please sign in to verify your email address.',
        'created_at': DateTime.now().toIso8601String(),
        'processed': false,
      });

      AppLogger.logger
          .auth('📧 Verification reminder created for: $cleanEmail');
    } catch (e) {
      AppLogger.logger.e('❌ Error sending verification reminder', error: e);
      throw AuthException(
        'Failed to send verification reminder: ${e.toString()}',
        code: 'verification-reminder-error',
      );
    }
  }
}

// Custom Auth Exception class for better error handling
class AuthException implements Exception {
  final String message;
  final String code;

  const AuthException(this.message, {required this.code});

  @override
  String toString() => message;
}

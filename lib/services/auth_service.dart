import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../models/models.dart';
import '../core/utils/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/utils/safe_query.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

class AuthService {
  // Lazy-loaded Firebase instances to prevent early initialization
  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  /// 🔥 PRODUCTION-GRADE GOOGLE SIGN-IN CONFIGURATION
  /// Fixed to work with multiple environments and proper error handling
  late final GoogleSignIn _googleSignIn;

  AuthService() {
    _initializeGoogleSignIn();
  }

  void _initializeGoogleSignIn() {
    try {
      // 🎯 FLEXIBLE CONFIGURATION - Works across dev/prod environments
      _googleSignIn = GoogleSignIn(
        scopes: [
          'email',
          'profile',
          'openid', // Add OpenID for better compatibility
        ],
        // Remove hardcoded serverClientId - let Firebase auto-configure
        // This prevents configuration mismatches across environments
      );

      AppLogger.logger.auth('✅ Google Sign-In initialized successfully');
    } catch (e) {
      AppLogger.logger.e('❌ Failed to initialize Google Sign-In', error: e);

      // Fallback configuration
      _googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );
    }
  }

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

  /// 🚀 COMPLETELY FIXED GOOGLE SIGN-IN with production-grade error handling
  Future<UserCredential> signInWithGoogle() async {
    try {
      AppLogger.logger.auth('🔐 Starting Google sign-in process...');

      // 1. CHECK GOOGLE PLAY SERVICES AVAILABILITY (Android)
      try {
        final isSignedIn = await _googleSignIn.isSignedIn();
        AppLogger.logger.auth('Google Sign-In status check: $isSignedIn');
      } catch (e) {
        AppLogger.logger.w('⚠️ Google Sign-In status check failed', error: e);
      }

      // 2. SIGN OUT FIRST to ensure clean state
      try {
        await _googleSignIn.signOut();
        AppLogger.logger.auth('🔄 Cleaned Google Sign-In state');
      } catch (e) {
        AppLogger.logger.w('⚠️ Google Sign-In cleanup warning', error: e);
        // Continue anyway - this is not critical
      }

      // 3. TRIGGER GOOGLE AUTHENTICATION FLOW
      AppLogger.logger.auth('🎯 Triggering Google authentication flow...');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        AppLogger.logger.auth('❌ Google sign-in cancelled by user');
        throw const AuthException(
          'Google sign-in was cancelled',
          code: 'sign-in-cancelled',
        );
      }

      AppLogger.logger.auth('✅ Google user obtained: ${googleUser.email}');

      // 4. GET AUTHENTICATION DETAILS
      AppLogger.logger.auth('🔑 Getting Google authentication tokens...');
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 5. VALIDATE TOKENS
      if (googleAuth.accessToken == null) {
        AppLogger.logger.e('❌ Google access token is null');
        throw const AuthException(
          'Failed to get Google access token. Please try again.',
          code: 'token-error',
        );
      }

      if (googleAuth.idToken == null) {
        AppLogger.logger.e('❌ Google ID token is null');
        throw const AuthException(
          'Failed to get Google ID token. Please try again.',
          code: 'token-error',
        );
      }

      AppLogger.logger.auth('✅ Google tokens obtained successfully');

      // 6. CREATE FIREBASE CREDENTIAL
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      AppLogger.logger.auth('🔑 Firebase credential created, signing in...');

      // 7. SIGN IN TO FIREBASE
      final userCredential = await _auth.signInWithCredential(credential);

      AppLogger.logger.auth('✅ Google sign-in completed successfully!');
      AppLogger.logger.auth('👤 User: ${userCredential.user?.email}');
      AppLogger.logger
          .auth('📧 Email verified: ${userCredential.user?.emailVerified}');

      return userCredential;
    } on FirebaseAuthException catch (e) {
      AppLogger.logger.e(
        '❌ Firebase Auth Error during Google sign-in',
        error: e,
        stackTrace: StackTrace.current,
      );

      // Provide user-friendly error messages
      switch (e.code) {
        case 'account-exists-with-different-credential':
          throw AuthException(
            'An account with this email already exists using a different sign-in method. Please try signing in with email/password.',
            code: e.code,
          );
        case 'invalid-credential':
          throw AuthException(
            'Google sign-in failed due to invalid credentials. Please try again.',
            code: e.code,
          );
        case 'operation-not-allowed':
          throw AuthException(
            'Google sign-in is not configured properly. Please contact support.',
            code: e.code,
          );
        case 'user-disabled':
          throw AuthException(
            'This account has been disabled. Please contact support.',
            code: e.code,
          );
        case 'network-request-failed':
          throw AuthException(
            'Network error. Please check your internet connection and try again.',
            code: e.code,
          );
        case 'web-context-canceled':
          throw AuthException(
            'Google sign-in was cancelled',
            code: e.code,
          );
        default:
          AppLogger.logger
              .e('❌ Unhandled Firebase Auth error: ${e.code} - ${e.message}');
          throw AuthException(
            'Google sign-in failed: ${e.message ?? 'Please try again or contact support.'}',
            code: e.code,
          );
      }
    } on Exception catch (e) {
      AppLogger.logger.e(
        '❌ General exception during Google sign-in',
        error: e,
        stackTrace: StackTrace.current,
      );

      // Handle specific Google Sign-In exceptions
      final errorMessage = e.toString().toLowerCase();

      if (errorMessage.contains('developer_error') ||
          errorMessage.contains('10')) {
        throw const AuthException(
          'Google sign-in configuration error. The app needs to be configured with proper SHA-1 certificates. Please contact support.',
          code: 'configuration-error',
        );
      }

      if (errorMessage.contains('network') ||
          errorMessage.contains('timeout')) {
        throw const AuthException(
          'Network error during Google sign-in. Please check your internet connection.',
          code: 'network-error',
        );
      }

      if (errorMessage.contains('sign_in_canceled') ||
          errorMessage.contains('cancelled')) {
        throw const AuthException(
          'Google sign-in was cancelled',
          code: 'sign-in-cancelled',
        );
      }

      throw AuthException(
        'Google sign-in failed: ${e.toString()}',
        code: 'unknown-error',
      );
    } catch (e, stackTrace) {
      AppLogger.logger.e(
        '❌ Unexpected error during Google sign-in',
        error: e,
        stackTrace: stackTrace,
      );

      throw const AuthException(
        'An unexpected error occurred during Google sign-in. Please try again.',
        code: 'unknown-error',
      );
    }
  }

  /// 🔧 GOOGLE SIGN-IN DIAGNOSTIC HELPER
  Future<Map<String, dynamic>> diagnoseGoogleSignIn() async {
    final diagnostics = <String, dynamic>{};

    try {
      diagnostics['timestamp'] = DateTime.now().toIso8601String();
      diagnostics['google_sign_in_available'] = true;

      // Check if already signed in
      final isSignedIn = await _googleSignIn.isSignedIn();
      diagnostics['already_signed_in'] = isSignedIn;

      if (isSignedIn) {
        final currentAccount = _googleSignIn.currentUser;
        diagnostics['current_user_email'] = currentAccount?.email;
      }

      // Test configuration
      diagnostics['configured_scopes'] = _googleSignIn.scopes;

      AppLogger.logger.auth('📊 Google Sign-In diagnostics: $diagnostics');
    } catch (e) {
      diagnostics['error'] = e.toString();
      diagnostics['google_sign_in_available'] = false;
      AppLogger.logger.e('❌ Google Sign-In diagnostics failed', error: e);
    }

    return diagnostics;
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
        AppLogger.logger.auth('✅ Google sign-out successful');
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
  Future<UserModel> getCurrentUserProfile() async {
    if (!isAuthenticated) {
      throw const AuthException('User not authenticated',
          code: 'not-authenticated');
    }

    final result = await SafeQuery.firestore(
      operation: () async {
        final doc =
            await _firestore.collection('users').doc(currentUser!.uid).get();
        if (!doc.exists) {
          throw const AuthException('User profile not found',
              code: 'profile-not-found');
        }
        return UserModel.fromJson(doc.data()!);
      },
      operationName: 'getCurrentUserProfile',
      onError: (e) {
        AppLogger.logger.e('❌ Failed to get user profile', error: e);
        throw AuthException(
          'Failed to get user profile: ${e.toString()}',
          code: 'profile-fetch-error',
        );
      },
    );
    if (result == null) {
      throw const AuthException('Unknown error fetching user profile',
          code: 'unknown-profile-error');
    }
    return result;
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

    final userData = {
      'id': user.uid,
      'email': user.email!,
      'name': name,
      'role': role.name,
      'avatar_url': user.photoURL ??
          'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=238636&color=FFFFFF',
      'bio': bio,
      'github_url': githubUrl,
      'skills': skills,
      'is_email_verified': user.emailVerified,
      'is_profile_complete': true,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    };

    final result = await SafeQuery.firestore(
      operation: () async {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(userData, SetOptions(merge: true));
        return UserModel.fromJson(userData);
      },
      operationName: 'upsertUserProfile',
      onError: (e) {
        AppLogger.logger.e('❌ Failed to upsert user profile', error: e);
        throw AuthException(
          'Failed to update user profile: ${e.toString()}',
          code: 'profile-update-error',
        );
      },
    );
    if (result == null) {
      throw const AuthException(
          'Failed to create/update user profile: Unknown error',
          code: 'unknown-profile-error');
    }
    return result;
  }

  // Check if user profile exists
  Future<bool> hasUserProfile() async {
    if (!isAuthenticated) return false;

    return await SafeQuery.firestore(
          operation: () async {
            final doc = await _firestore
                .collection('users')
                .doc(currentUser!.uid)
                .get();
            return doc.exists;
          },
          operationName: 'hasUserProfile',
          fallbackValue: false,
          onError: (e) {
            AppLogger.logger
                .e('❌ Failed to check user profile existence', error: e);
          },
        ) ??
        false; // Return false if safeQuery returns null
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
      'updated_at': FieldValue.serverTimestamp(),
    };

    if (name != null) updateData['name'] = name;
    if (bio != null) updateData['bio'] = bio;
    if (githubUrl != null) updateData['github_url'] = githubUrl;
    if (skills != null) updateData['skills'] = skills;
    if (avatarUrl != null) updateData['avatar_url'] = avatarUrl;

    final result = await SafeQuery.generic(
      operation: () async {
        await _firestore
            .collection('users')
            .doc(currentUser!.uid)
            .update(updateData);

        final doc =
            await _firestore.collection('users').doc(currentUser!.uid).get();

        return UserModel.fromJson(doc.data()!);
      },
      operationName: 'updateUserProfile',
      fallbackValue: null,
      onError: (e) {
        AppLogger.logger.e('❌ Failed to update user profile', error: e);
        throw AuthException(
          'Failed to update user profile: ${e.toString()}',
          code: 'profile-update-error',
        );
      },
    );
    if (result == null) {
      throw const AuthException('Failed to update user profile: Unknown error',
          code: 'unknown-profile-error');
    }
    return result;
  }

  // Delete user account
  Future<void> deleteAccount() async {
    if (!isAuthenticated) {
      throw const AuthException(
        'User must be authenticated',
        code: 'not-authenticated',
      );
    }

    await SafeQuery.generic(
      operation: () async {
        // Delete user data from Firestore
        await _firestore.collection('users').doc(currentUser!.uid).delete();

        // Sign out from all providers
        await signOut();

        // Delete the user account
        await currentUser!.delete();
      },
      operationName: 'deleteAccount',
      onError: (e) {
        AppLogger.logger.e('❌ Failed to delete account', error: e);
        throw AuthException(
          'Failed to delete account: ${e.toString()}',
          code: 'account-deletion-error',
        );
      },
    );
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

    await SafeQuery.generic(
      operation: () async {
        await user.sendEmailVerification();
        AppLogger.logger.auth('📧 Email verification sent to: ${user.email}');
      },
      operationName: 'sendEmailVerification',
      onError: (e) {
        AppLogger.logger.e('❌ Error sending email verification', error: e);
        if (e is FirebaseAuthException) {
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
        } else {
          throw const AuthException(
            'Failed to send verification email. Please try again.',
            code: 'unknown-error',
          );
        }
      },
    );
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

    await SafeQuery.generic(
      operation: () async {
        await user.reload();
        AppLogger.logger.auth('🔄 User data reloaded for: ${user.email}');
      },
      operationName: 'reloadUser',
      onError: (e) {
        AppLogger.logger.e('❌ Error reloading user', error: e);
        throw const AuthException(
          'Failed to refresh user data. Please try again.',
          code: 'reload-error',
        );
      },
    );
  }

  /// Send verification email to a specific user by email (for existing users)
  Future<void> sendVerificationToUser(String email) async {
    if (!isAuthenticated) {
      throw const AuthException(
        'Must be authenticated to perform this action.',
        code: 'unauthenticated',
      );
    }

    final cleanEmail = email.trim();
    if (!_isValidEmail(cleanEmail)) {
      throw const AuthException(
        'Invalid email format.',
        code: 'invalid-email',
      );
    }

    await SafeQuery.generic(
      operation: () async {
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
      },
      operationName: 'sendVerificationToUser',
      onError: (e) {
        AppLogger.logger.e('❌ Error sending verification reminder', error: e);
        throw AuthException(
          'Failed to send verification reminder: ${e.toString()}',
          code: 'verification-reminder-error',
        );
      },
    );
  }

  /// 🚀 GITHUB SIGN-IN (Firebase Auth)
  /// Returns a tuple: (UserCredential?, needsLinking: bool, existingProvider: String?)
  Future<(UserCredential?, bool, String?)> signInWithGitHubWithLinking() async {
    try {
      AppLogger.logger.auth('🔐 Starting GitHub sign-in process...');
      if (kIsWeb) {
        GithubAuthProvider githubProvider = GithubAuthProvider();
        githubProvider.addScope('read:user');
        githubProvider.setCustomParameters({'allow_signup': 'true'});
        final userCredential = await _auth.signInWithPopup(githubProvider);
        AppLogger.logger.auth('✅ GitHub sign-in completed (web)');
        return (userCredential, false, null);
      } else {
        GithubAuthProvider githubProvider = GithubAuthProvider();
        githubProvider.addScope('read:user');
        githubProvider.setCustomParameters({'allow_signup': 'true'});
        final userCredential = await _auth.signInWithProvider(githubProvider);
        AppLogger.logger.auth('✅ GitHub sign-in completed (mobile)');
        return (userCredential, false, null);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        final email = e.email;
        final pendingCredential = e.credential;
        if (email != null && pendingCredential != null) {
          final methods = await _auth.fetchSignInMethodsForEmail(email);
          final existingProvider = methods.isNotEmpty ? methods.first : null;
          // Return null user, needsLinking true, and the existing provider
          return (null, true, existingProvider);
        }
      }
      AppLogger.logger
          .e('❌ Firebase Auth Error during GitHub sign-in', error: e);
      throw AuthException(
        'GitHub sign-in failed: ${e.message ?? 'Please try again or contact support.'}',
        code: e.code,
      );
    } catch (e, stackTrace) {
      AppLogger.logger.e('❌ General exception during GitHub sign-in',
          error: e, stackTrace: stackTrace);
      throw const AuthException(
        'An unexpected error occurred during GitHub sign-in. Please try again.',
        code: 'unknown-error',
      );
    }
  }

  /// Link a pending GitHub credential to the currently signed-in user
  Future<UserCredential> linkGitHubCredential(
      AuthCredential pendingCredential) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const AuthException('No user to link credential to.',
          code: 'no-user');
    }
    return await user.linkWithCredential(pendingCredential);
  }

  /// 🚀 GITHUB OAUTH AUTHENTICATION for mobile using flutter_web_auth_2
  Future<UserCredential> signInWithGitHubMobile() async {
    try {
      AppLogger.logger.auth('🐙 Starting GitHub OAuth authentication...');
      final clientId = dotenv.env['GITHUB_CLIENT_ID'];
      final clientSecret = dotenv.env['GITHUB_CLIENT_SECRET'];
      final redirectUri = dotenv.env['GITHUB_REDIRECT_URI'];
      if (clientId == null || clientSecret == null || redirectUri == null) {
        AppLogger.logger.e('❌ GitHub OAuth credentials not configured');
        throw const AuthException(
          'GitHub authentication is not configured. Please contact support.',
          code: 'github-not-configured',
        );
      }
      final authUrl =
          Uri.parse('https://github.com/login/oauth/authorize').replace(
        queryParameters: {
          'client_id': clientId,
          'redirect_uri': redirectUri,
          'scope': 'user:email read:user',
          'state': DateTime.now().millisecondsSinceEpoch.toString(),
        },
      );
      final result = await FlutterWebAuth2.authenticate(
        url: authUrl.toString(),
        callbackUrlScheme: 'com.gitalong.app',
      );
      final callbackUrl = Uri.parse(result);
      final code = callbackUrl.queryParameters['code'];
      if (code == null) {
        AppLogger.logger.e('❌ No authorization code received from GitHub');
        throw const AuthException(
          'Failed to get authorization code from GitHub. Please try again.',
          code: 'no-auth-code',
        );
      }
      final tokenResponse = await http.post(
        Uri.parse('https://github.com/login/oauth/access_token'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'client_id': clientId,
          'client_secret': clientSecret,
          'code': code,
          'redirect_uri': redirectUri,
        }),
      );
      if (tokenResponse.statusCode != 200) {
        AppLogger.logger.e(
            '❌ Failed to exchange code for token: ${tokenResponse.statusCode}');
        throw const AuthException(
          'Failed to complete GitHub authentication. Please try again.',
          code: 'token-exchange-failed',
        );
      }
      final tokenData = jsonDecode(tokenResponse.body) as Map<String, dynamic>;
      final accessToken = tokenData['access_token'] as String?;
      if (accessToken == null) {
        AppLogger.logger.e('❌ No access token received from GitHub');
        throw const AuthException(
          'Failed to get access token from GitHub. Please try again.',
          code: 'no-access-token',
        );
      }
      final credential = GithubAuthProvider.credential(accessToken);
      final userCredential = await _auth.signInWithCredential(credential);
      AppLogger.logger.auth('✅ GitHub sign-in completed successfully!');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      AppLogger.logger.e('❌ Firebase Auth Error during GitHub sign-in',
          error: e, stackTrace: StackTrace.current);
      throw AuthException(
        'GitHub sign-in failed: ${e.message ?? 'Please try again or contact support.'}',
        code: e.code,
      );
    } on AuthException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.logger.e('❌ Unexpected error during GitHub sign-in',
          error: e, stackTrace: stackTrace);
      throw AuthException(
        'An unexpected error occurred during GitHub sign-in. Please try again.',
        code: 'unknown-error',
      );
    }
  }

  /// Anonymous sign-in for guest users
  Future<UserCredential> signInAnonymously() async {
    try {
      AppLogger.logger.auth('🔓 Signing in anonymously (guest)...');
      final userCred = await _auth.signInAnonymously();
      AppLogger.logger
          .auth('✅ Guest sign-in successful: \\${userCred.user?.uid}');
      return userCred;
    } on FirebaseAuthException catch (e) {
      AppLogger.logger
          .e('❌ Firebase Auth Error during anonymous sign-in', error: e);
      throw AuthException(
        'Guest sign-in failed: ${e.message ?? 'Please try again.'}',
        code: e.code,
      );
    } catch (e, stackTrace) {
      AppLogger.logger.e('❌ Exception during anonymous sign-in',
          error: e, stackTrace: stackTrace);
      throw const AuthException('Guest sign-in failed. Please try again.',
          code: 'unknown-error');
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

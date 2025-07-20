import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import '../models/models.dart';
import '../core/utils/logger.dart';
import '../core/utils/safe_query.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:crypto/crypto.dart';
import 'dart:math';

/// 🔥 PRODUCTION-GRADE AUTHENTICATION SERVICE
/// Secure, scalable, and enterprise-ready authentication system
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Lazy-loaded Firebase instances to prevent early initialization
  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  // Secure storage for sensitive data
  final _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  // Google Sign-In configuration
  late final GoogleSignIn _googleSignIn;
  static bool _googleSignInInitialized = false;

  /// Initialize the authentication service
  Future<void> initialize() async {
    try {
      AppLogger.logger.i('🔐 Initializing AuthService...');

      if (!_googleSignInInitialized) {
        await _initializeGoogleSignIn();
        _googleSignInInitialized = true;
      }

      AppLogger.logger.success('✅ AuthService initialized successfully');
    } catch (e, stackTrace) {
      AppLogger.logger.e('❌ Failed to initialize AuthService',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Initialize Google Sign-In with proper configuration
  Future<void> _initializeGoogleSignIn() async {
    try {
      _googleSignIn = GoogleSignIn(
        scopes: [
          'email',
          'profile',
          'openid',
        ],
        // Let Firebase auto-configure - no hardcoded client IDs
      );
      AppLogger.logger.auth('✅ Google Sign-In initialized successfully');
    } catch (e) {
      AppLogger.logger.e('❌ Failed to initialize Google Sign-In', error: e);
      rethrow;
    }
  }

  // ============================================================================
  // 🔐 AUTHENTICATION METHODS
  // ============================================================================

  /// Get current authenticated user
  User? get currentUser => _auth.currentUser;

  /// Get auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Check if user is authenticated
  bool get isAuthenticated => _auth.currentUser != null;

  /// Sign in with email and password with comprehensive error handling
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Input validation and sanitization
      final cleanEmail = email.trim().toLowerCase();
      final cleanPassword = password.trim();

      if (cleanEmail.isEmpty) {
        throw const AuthException('Email cannot be empty', code: 'empty-email');
      }
      if (cleanPassword.isEmpty) {
        throw const AuthException('Password cannot be empty',
            code: 'empty-password');
      }
      if (!_isValidEmail(cleanEmail)) {
        throw const AuthException('Invalid email format',
            code: 'invalid-email');
      }

      AppLogger.logger.auth('🔐 Attempting email sign-in for: $cleanEmail');

      final credential = await _auth.signInWithEmailAndPassword(
        email: cleanEmail,
        password: cleanPassword,
      );

      // Track successful sign-in
      await _trackAuthEvent('email_sign_in_success', cleanEmail);

      AppLogger.logger.auth('✅ Email sign-in successful for: $cleanEmail');
      return credential;
    } on FirebaseAuthException catch (e) {
      AppLogger.logger
          .e('❌ Firebase Auth Error during email sign-in', error: e);
      await _trackAuthEvent('email_sign_in_failed', email, error: e.code);
      throw _handleFirebaseAuthException(e);
    } catch (e, stackTrace) {
      AppLogger.logger.e('❌ Unexpected error during email sign-in',
          error: e, stackTrace: stackTrace);
      await _trackAuthEvent('email_sign_in_error', email, error: e.toString());
      throw AuthException('An unexpected error occurred. Please try again.',
          code: 'unknown-error');
    }
  }

  /// Create user with email and password
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final cleanEmail = email.trim().toLowerCase();
      final cleanPassword = password.trim();
      final cleanDisplayName = displayName?.trim();

      // Comprehensive validation
      if (cleanEmail.isEmpty) {
        throw const AuthException('Email cannot be empty', code: 'empty-email');
      }
      if (cleanPassword.isEmpty) {
        throw const AuthException('Password cannot be empty',
            code: 'empty-password');
      }
      if (!_isValidEmail(cleanEmail)) {
        throw const AuthException('Invalid email format',
            code: 'invalid-email');
      }
      if (!_isValidPassword(cleanPassword)) {
        throw const AuthException(
            'Password must be at least 8 characters and contain uppercase, lowercase, and numbers',
            code: 'weak-password');
      }

      AppLogger.logger.auth('🔐 Attempting email sign-up for: $cleanEmail');

      final credential = await _auth.createUserWithEmailAndPassword(
        email: cleanEmail,
        password: cleanPassword,
      );

      // Update display name if provided
      if (cleanDisplayName != null && cleanDisplayName.isNotEmpty) {
        await credential.user?.updateDisplayName(cleanDisplayName);
      }

      // Create user profile in Firestore
      await _createUserProfile(credential.user!, cleanDisplayName);

      await _trackAuthEvent('email_sign_up_success', cleanEmail);

      AppLogger.logger.auth('✅ Email sign-up successful for: $cleanEmail');
      return credential;
    } on FirebaseAuthException catch (e) {
      AppLogger.logger
          .e('❌ Firebase Auth Error during email sign-up', error: e);
      await _trackAuthEvent('email_sign_up_failed', email, error: e.code);
      throw _handleFirebaseAuthException(e);
    } catch (e, stackTrace) {
      AppLogger.logger.e('❌ Unexpected error during email sign-up',
          error: e, stackTrace: stackTrace);
      await _trackAuthEvent('email_sign_up_error', email, error: e.toString());
      throw AuthException('An unexpected error occurred. Please try again.',
          code: 'unknown-error');
    }
  }

  /// Sign in with Google
  Future<UserCredential> signInWithGoogle() async {
    try {
      AppLogger.logger.auth('🔐 Attempting Google sign-in...');

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw const AuthException('Google sign-in was cancelled',
            code: 'cancelled');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      // Create or update user profile
      await _createUserProfile(userCredential.user!, googleUser.displayName);

      await _trackAuthEvent('google_sign_in_success', googleUser.email);

      AppLogger.logger
          .auth('✅ Google sign-in successful for: ${googleUser.email}');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      AppLogger.logger
          .e('❌ Firebase Auth Error during Google sign-in', error: e);
      await _trackAuthEvent('google_sign_in_failed', null, error: e.code);
      throw _handleFirebaseAuthException(e);
    } catch (e, stackTrace) {
      AppLogger.logger.e('❌ Unexpected error during Google sign-in',
          error: e, stackTrace: stackTrace);
      await _trackAuthEvent('google_sign_in_error', null, error: e.toString());
      throw AuthException('Google sign-in failed. Please try again.',
          code: 'google-signin-error');
    }
  }

  /// Sign in with Apple (iOS only)
  Future<UserCredential> signInWithApple() async {
    try {
      AppLogger.logger.auth('🔐 Attempting Apple sign-in...');

      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      final userCredential = await _auth.signInWithCredential(oauthCredential);

      // Create or update user profile
      final displayName =
          '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'
              .trim();
      await _createUserProfile(
          userCredential.user!, displayName.isNotEmpty ? displayName : null);

      await _trackAuthEvent(
          'apple_sign_in_success', userCredential.user?.email);

      AppLogger.logger.auth('✅ Apple sign-in successful');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      AppLogger.logger
          .e('❌ Firebase Auth Error during Apple sign-in', error: e);
      await _trackAuthEvent('apple_sign_in_failed', null, error: e.code);
      throw _handleFirebaseAuthException(e);
    } catch (e, stackTrace) {
      AppLogger.logger.e('❌ Unexpected error during Apple sign-in',
          error: e, stackTrace: stackTrace);
      await _trackAuthEvent('apple_sign_in_error', null, error: e.toString());
      throw AuthException('Apple sign-in failed. Please try again.',
          code: 'apple-signin-error');
    }
  }

  /// Sign out user
  Future<void> signOut() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _trackAuthEvent('sign_out', user.email);
      }

      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);

      // Clear secure storage
      await _secureStorage.deleteAll();

      AppLogger.logger.auth('✅ User signed out successfully');
    } catch (e, stackTrace) {
      AppLogger.logger
          .e('❌ Error during sign out', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      final cleanEmail = email.trim().toLowerCase();

      if (cleanEmail.isEmpty) {
        throw const AuthException('Email cannot be empty', code: 'empty-email');
      }
      if (!_isValidEmail(cleanEmail)) {
        throw const AuthException('Invalid email format',
            code: 'invalid-email');
      }

      await _auth.sendPasswordResetEmail(email: cleanEmail);
      await _trackAuthEvent('password_reset_sent', cleanEmail);

      AppLogger.logger.auth('✅ Password reset email sent to: $cleanEmail');
    } on FirebaseAuthException catch (e) {
      AppLogger.logger
          .e('❌ Firebase Auth Error sending password reset', error: e);
      await _trackAuthEvent('password_reset_failed', email, error: e.code);
      throw _handleFirebaseAuthException(e);
    } catch (e, stackTrace) {
      AppLogger.logger.e('❌ Unexpected error sending password reset',
          error: e, stackTrace: stackTrace);
      throw AuthException(
          'Failed to send password reset email. Please try again.',
          code: 'reset-error');
    }
  }

  /// Delete user account
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw const AuthException('No user is currently signed in',
            code: 'no-user');
      }

      // Delete user data from Firestore first
      await _deleteUserProfile(user.uid);

      // Delete Firebase Auth account
      await user.delete();

      await _trackAuthEvent('account_deleted', user.email);

      AppLogger.logger.auth('✅ User account deleted successfully');
    } on FirebaseAuthException catch (e) {
      AppLogger.logger.e('❌ Firebase Auth Error deleting account', error: e);
      throw _handleFirebaseAuthException(e);
    } catch (e, stackTrace) {
      AppLogger.logger.e('❌ Unexpected error deleting account',
          error: e, stackTrace: stackTrace);
      throw AuthException('Failed to delete account. Please try again.',
          code: 'delete-error');
    }
  }

  // ============================================================================
  // 🔧 UTILITY METHODS
  // ============================================================================

  /// Create or update user profile in Firestore
  Future<void> _createUserProfile(User user, String? displayName) async {
    try {
      final userData = {
        'uid': user.uid,
        'email': user.email,
        'displayName': displayName ?? user.displayName,
        'photoURL': user.photoURL,
        'emailVerified': user.emailVerified,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'lastSignInAt': FieldValue.serverTimestamp(),
        'providerData': user.providerData
            .map((p) => {
                  'providerId': p.providerId,
                  'uid': p.uid,
                  'displayName': p.displayName,
                  'email': p.email,
                  'photoURL': p.photoURL,
                })
            .toList(),
      };

      await _firestore.collection('users').doc(user.uid).set(
            userData,
            SetOptions(merge: true),
          );

      AppLogger.logger.d('✅ User profile created/updated in Firestore');
    } catch (e, stackTrace) {
      AppLogger.logger
          .e('❌ Error creating user profile', error: e, stackTrace: stackTrace);
      // Don't throw here - auth should still succeed even if profile creation fails
    }
  }

  /// Delete user profile from Firestore
  Future<void> _deleteUserProfile(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).delete();
      AppLogger.logger.d('✅ User profile deleted from Firestore');
    } catch (e, stackTrace) {
      AppLogger.logger
          .e('❌ Error deleting user profile', error: e, stackTrace: stackTrace);
      // Don't throw here - account deletion should still proceed
    }
  }

  /// Track authentication events for analytics
  Future<void> _trackAuthEvent(String event, String? email,
      {String? error}) async {
    try {
      await _firestore.collection('auth_events').add({
        'event': event,
        'email': email,
        'error': error,
        'timestamp': FieldValue.serverTimestamp(),
        'userId': _auth.currentUser?.uid,
        'userAgent': 'flutter_app',
      });
    } catch (e) {
      AppLogger.logger.w('⚠️ Failed to track auth event: $e');
    }
  }

  /// Handle Firebase Auth exceptions with user-friendly messages
  AuthException _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return const AuthException(
          'No account found with this email. Please sign up first.',
          code: 'user-not-found',
        );
      case 'wrong-password':
        return const AuthException(
          'Incorrect password. Please try again.',
          code: 'wrong-password',
        );
      case 'invalid-credential':
        return const AuthException(
          'Invalid email or password. Please check your credentials.',
          code: 'invalid-credential',
        );
      case 'invalid-email':
        return const AuthException(
          'Invalid email format. Please enter a valid email.',
          code: 'invalid-email',
        );
      case 'user-disabled':
        return const AuthException(
          'This account has been disabled. Please contact support.',
          code: 'user-disabled',
        );
      case 'too-many-requests':
        return const AuthException(
          'Too many failed attempts. Please try again later.',
          code: 'too-many-requests',
        );
      case 'operation-not-allowed':
        return const AuthException(
          'This sign-in method is not enabled. Please contact support.',
          code: 'operation-not-allowed',
        );
      case 'network-request-failed':
        return const AuthException(
          'Network error. Please check your internet connection.',
          code: 'network-request-failed',
        );
      case 'email-already-in-use':
        return const AuthException(
          'An account with this email already exists. Please sign in instead.',
          code: 'email-already-in-use',
        );
      case 'weak-password':
        return const AuthException(
          'Password is too weak. Please choose a stronger password.',
          code: 'weak-password',
        );
      case 'requires-recent-login':
        return const AuthException(
          'This operation requires recent authentication. Please sign in again.',
          code: 'requires-recent-login',
        );
      default:
        return AuthException(
          'Authentication failed: ${e.message ?? 'Unknown error'}',
          code: e.code,
        );
    }
  }

  /// Validate email format
  bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email);
  }

  /// Validate password strength
  bool _isValidPassword(String password) {
    return password.length >= 8 &&
        RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[a-z]').hasMatch(password) &&
        RegExp(r'[0-9]').hasMatch(password);
  }

  /// Generate nonce for Apple Sign-In
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// SHA256 hash for Apple Sign-In
  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}

/// Custom authentication exception
class AuthException implements Exception {
  final String message;
  final String code;

  const AuthException(this.message, {required this.code});

  @override
  String toString() => 'AuthException($code): $message';
}

/// Provider for AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

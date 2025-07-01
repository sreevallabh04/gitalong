import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:io';
import '../config/firebase_config.dart';
import '../models/models.dart';
import '../core/utils/logger.dart';

class AuthService {
  // Lazy-loaded Firebase instances to prevent early initialization
  FirebaseAuth get _auth => FirebaseConfig.auth;
  FirebaseFirestore get _firestore => FirebaseConfig.firestore;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  // Sign up with email and password
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update user display name
      await credential.user?.updateDisplayName(name);

      // Create user profile in Firestore
      if (credential.user != null) {
        await _createUserProfile(
          user: credential.user!,
          name: name,
          role: UserRole.contributor, // Default role
        );
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    } catch (e) {
      throw AuthException('Failed to create account: ${e.toString()}');
    }
  }

  // Sign in with email and password
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    } catch (e) {
      throw AuthException('Failed to sign in: ${e.toString()}');
    }
  }

  // Sign in with Google
  Future<UserCredential> signInWithGoogle() async {
    try {
      AppLogger.logger.auth('🔐 Starting Google Sign-In process...');

      // Enhanced configuration validation
      if (_googleSignIn.clientId == null) {
        AppLogger.logger
            .e('❌ Google Sign-In not configured - missing client ID');
        throw const AuthException('🔧 Google Sign-In Configuration Required\n\n'
            'To enable Google Sign-In:\n'
            '1. Add SHA-1 fingerprint to Firebase console\n'
            '2. Download updated google-services.json\n'
            '3. Rebuild the app\n\n'
            'See FIREBASE_SETUP_GUIDE.md for details.');
      }

      // Log Google Sign-In configuration details
      AppLogger.logger.d('Google Sign-In scopes: ${_googleSignIn.scopes}');
      AppLogger.logger.d(
          'Google Sign-In client ID: ${_googleSignIn.clientId != null ? "CONFIGURED" : "NOT_SET"}');

      // Check current sign-in status
      final bool wasSignedIn = await _googleSignIn.isSignedIn();
      AppLogger.logger.d('Previous Google sign-in status: $wasSignedIn');

      // Sign out from any previous Google sessions to ensure clean state
      if (wasSignedIn) {
        AppLogger.logger.d('Signing out from previous Google session...');
        await _googleSignIn.signOut();
      }

      AppLogger.logger.d('Attempting Google Sign-In...');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        AppLogger.logger.w('🚫 Google sign-in was cancelled by user');
        throw const AuthException('Google sign in was cancelled');
      }

      AppLogger.logger
          .auth('✅ Google user account selected: ${googleUser.email}');
      AppLogger.logger.d(
          'Google user details - Name: ${googleUser.displayName}, ID: ${googleUser.id}');

      AppLogger.logger.d('Getting Google authentication tokens...');
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      AppLogger.logger.d('Google auth tokens received:');
      AppLogger.logger.d(
          '  - Access Token: ${googleAuth.accessToken != null ? "PRESENT" : "MISSING"}');
      AppLogger.logger.d(
          '  - ID Token: ${googleAuth.idToken != null ? "PRESENT" : "MISSING"}');

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        AppLogger.logger
            .e('❌ Failed to get Google credentials - tokens are null');
        throw const AuthException('Failed to get Google credentials');
      }

      // Create a new credential
      AppLogger.logger.d('Creating Firebase credential...');
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      AppLogger.logger
          .auth('🔑 Attempting Firebase sign-in with Google credential...');
      final userCredential = await _auth.signInWithCredential(credential);

      AppLogger.logger.auth('🎉 Firebase sign-in successful!');
      AppLogger.logger.d('Firebase user: ${userCredential.user?.email}');

      // Create or update user profile in Firestore
      if (userCredential.user != null) {
        AppLogger.logger.d('👤 Creating/updating user profile in Firestore...');
        await _createOrUpdateUserProfile(
          user: userCredential.user!,
          name: googleUser.displayName ?? 'Unknown',
          role: UserRole.contributor, // Default role
        );
        AppLogger.logger.auth('✅ User profile updated successfully');
      }

      return userCredential;
    } on FirebaseAuthException catch (e, stackTrace) {
      AppLogger.logger.e('🔥 Firebase Auth Exception during Google sign-in',
          error: e, stackTrace: stackTrace);
      AppLogger.logger.e('Firebase Auth Error Code: ${e.code}');
      AppLogger.logger.e('Firebase Auth Error Message: ${e.message}');
      throw _handleFirebaseAuthError(e);
    } catch (e, stackTrace) {
      AppLogger.logger.e('❌ Google sign-in failed with unexpected error',
          error: e, stackTrace: stackTrace);

      // Enhanced error analysis for common Google Sign-In issues
      final errorString = e.toString();

      // Don't show complex error analysis for user cancellation
      if (errorString.contains('sign in was cancelled')) {
        rethrow;
      }

      if (errorString.contains('ApiException: 10')) {
        AppLogger.logger.e('🔍 DEVELOPER_ERROR (Code 10) Analysis:');
        AppLogger.logger.e('   ❌ This indicates a configuration problem');
        AppLogger.logger.e('   📋 Common causes:');
        AppLogger.logger
            .e('      • google-services.json is missing or invalid');
        AppLogger.logger
            .e('      • SHA-1 fingerprint not added to Firebase console');
        AppLogger.logger.e(
            '      • Package name mismatch between app and Firebase project');
        AppLogger.logger.e('      • OAuth client not properly configured');
        throw const AuthException('🔧 App Configuration Required\n\n'
            'Google Sign-In requires proper Firebase configuration.\n\n'
            '📋 Required Steps:\n'
            '• Add SHA-1 fingerprint to Firebase console\n'
            '• Download updated google-services.json\n'
            '• Rebuild the app\n\n'
            'See FIREBASE_SETUP_GUIDE.md for detailed instructions.');
      } else if (errorString.contains('ApiException: 12500')) {
        AppLogger.logger.e(
            '🔍 SIGN_IN_REQUIRED (Code 12500): User not signed in to Google Play Services');
        throw const AuthException('🔐 Google Play Services Required\n\n'
            'Please sign in to Google Play Services on this device and try again.');
      } else if (errorString.contains('ApiException: 7')) {
        AppLogger.logger
            .e('🔍 NETWORK_ERROR (Code 7): Check internet connectivity');
        throw const AuthException('🌐 Network Error\n\n'
            'Please check your internet connection and try again.');
      } else if (errorString.contains('ApiException: 8')) {
        AppLogger.logger.e(
            '🔍 INTERNAL_ERROR (Code 8): Google Play Services internal error');
        throw const AuthException('⚠️ Google Play Services Error\n\n'
            'Please update Google Play Services and try again.');
      }

      throw AuthException('Google sign in failed: ${e.toString()}');
    }
  }

  // Sign in with Apple (iOS/macOS only)
  Future<UserCredential> signInWithApple() async {
    if (!Platform.isIOS && !Platform.isMacOS) {
      throw const AuthException(
        'Apple Sign In is only available on iOS and macOS',
      );
    }

    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      if (credential.identityToken == null) {
        throw const AuthException('Failed to get Apple ID credential');
      }

      // Create a new credential
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      final userCredential = await _auth.signInWithCredential(oauthCredential);

      // Create or update user profile in Firestore
      if (userCredential.user != null) {
        final name =
            credential.givenName != null && credential.familyName != null
                ? '${credential.givenName} ${credential.familyName}'
                : userCredential.user!.displayName ?? 'Unknown';

        await _createOrUpdateUserProfile(
          user: userCredential.user!,
          name: name,
          role: UserRole.contributor, // Default role
        );
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    } catch (e) {
      throw AuthException('Apple sign in failed: ${e.toString()}');
    }
  }

  // Send password reset email
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    } catch (e) {
      throw AuthException(
          'Failed to send password reset email: ${e.toString()}');
    }
  }

  // Update password
  Future<void> updatePassword(String newPassword) async {
    if (!isAuthenticated) {
      throw const AuthException('User must be authenticated');
    }

    try {
      await currentUser!.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    } catch (e) {
      throw AuthException('Failed to update password: ${e.toString()}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      // Sign out from Google if signed in
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      await _auth.signOut();
    } catch (e) {
      throw AuthException('Failed to sign out: ${e.toString()}');
    }
  }

  // Get current user profile
  Future<UserModel?> getCurrentUserProfile() async {
    if (!isAuthenticated) return null;

    try {
      final doc =
          await _firestore.collection('users').doc(currentUser!.uid).get();

      return doc.exists ? UserModel.fromJson(doc.data()!) : null;
    } catch (e) {
      throw AuthException('Failed to get user profile: ${e.toString()}');
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
      throw const AuthException('User must be authenticated');
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
      throw AuthException('Failed to update user profile: ${e.toString()}');
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
      throw const AuthException('User must be authenticated');
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
      throw AuthException('Failed to update user profile: ${e.toString()}');
    }
  }

  // Delete user account
  Future<void> deleteAccount() async {
    if (!isAuthenticated) {
      throw const AuthException('User must be authenticated');
    }

    try {
      // Delete user data from Firestore
      await _firestore.collection('users').doc(currentUser!.uid).delete();

      // Sign out from all providers
      await signOut();

      // Delete the user account
      await currentUser!.delete();
    } catch (e) {
      throw AuthException('Failed to delete account: ${e.toString()}');
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

  // Enhanced Firebase Auth error handling
  AuthException _handleFirebaseAuthError(FirebaseAuthException error) {
    String message;

    switch (error.code) {
      case 'user-not-found':
        message = 'No account found with this email address';
        break;
      case 'wrong-password':
        message = 'Incorrect password';
        break;
      case 'email-already-in-use':
        message = 'An account with this email already exists';
        break;
      case 'weak-password':
        message = 'Password must be at least 6 characters long';
        break;
      case 'invalid-email':
        message = 'Please enter a valid email address';
        break;
      case 'user-disabled':
        message = 'This account has been disabled';
        break;
      case 'too-many-requests':
        message = 'Too many failed attempts. Please try again later';
        break;
      case 'operation-not-allowed':
        message = 'This sign-in method is not enabled';
        break;
      case 'network-request-failed':
        message = 'Network error. Please check your connection';
        break;
      case 'requires-recent-login':
        message = 'Please sign in again to complete this action';
        break;
      default:
        message = error.message ?? 'An unknown error occurred';
    }

    return AuthException(message);
  }
}

class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}

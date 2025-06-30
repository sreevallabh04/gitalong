import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:io';
import '../config/firebase_config.dart';
import '../models/models.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseConfig.auth;
  final FirebaseFirestore _firestore = FirebaseConfig.firestore;
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
      // Sign out from any previous Google sessions
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw const AuthException('Google sign in was cancelled');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        throw const AuthException('Failed to get Google credentials');
      }

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      // Create or update user profile in Firestore
      if (userCredential.user != null) {
        await _createOrUpdateUserProfile(
          user: userCredential.user!,
          name: googleUser.displayName ?? 'Unknown',
          role: UserRole.contributor, // Default role
        );
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    } catch (e) {
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

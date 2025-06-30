import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:io';
import '../config/supabase_config.dart';
import '../models/models.dart';

class AuthService {
  final SupabaseClient _supabase = SupabaseConfig.client;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;

  // Get auth state stream
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  // Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name, 'avatar_url': null},
      );
      return response;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Sign in with Google
  Future<AuthResponse> signInWithGoogle() async {
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

      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken!,
      );

      return response;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Sign in with Apple (iOS/macOS only)
  Future<AuthResponse> signInWithApple() async {
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

      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: credential.identityToken!,
      );

      return response;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Sign in with GitHub (using Supabase OAuth)
  Future<bool> signInWithGitHub() async {
    try {
      final response = await _supabase.auth.signInWithOAuth(
        OAuthProvider.github,
        redirectTo: 'io.flutter.gitalong://auth-callback',
      );
      return response;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Send password reset email
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: 'io.flutter.gitalong://reset-password',
      );
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Update password
  Future<UserResponse> updatePassword(String newPassword) async {
    if (!isAuthenticated) {
      throw const AuthException('User must be authenticated');
    }

    try {
      final response = await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      return response;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      // Sign out from Google if signed in
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      await _supabase.auth.signOut();
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Get current user profile
  Future<UserModel?> getCurrentUserProfile() async {
    if (!isAuthenticated) return null;

    try {
      final response =
          await _supabase
              .from('users')
              .select()
              .eq('id', currentUser!.id)
              .maybeSingle();

      return response != null ? UserModel.fromJson(response) : null;
    } catch (e) {
      throw _handleAuthError(e);
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
      'id': user.id,
      'email': user.email!,
      'name': name,
      'role': role.name,
      'avatar_url':
          user.userMetadata?['avatar_url'] ??
          user.userMetadata?['picture'] ??
          'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=00F5FF&color=0A0A0F',
      'bio': bio,
      'github_url': githubUrl,
      'skills': skills,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    };

    try {
      final response =
          await _supabase.from('users').upsert(userData).select().single();

      return UserModel.fromJson(response);
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Check if user profile exists
  Future<bool> hasUserProfile() async {
    if (!isAuthenticated) return false;

    try {
      final response =
          await _supabase
              .from('users')
              .select('id')
              .eq('id', currentUser!.id)
              .maybeSingle();

      return response != null;
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
      final response =
          await _supabase
              .from('users')
              .update(updateData)
              .eq('id', currentUser!.id)
              .select()
              .single();

      return UserModel.fromJson(response);
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Refresh session
  Future<AuthResponse> refreshSession() async {
    try {
      final response = await _supabase.auth.refreshSession();
      return response;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Delete user account
  Future<void> deleteAccount() async {
    if (!isAuthenticated) {
      throw const AuthException('User must be authenticated');
    }

    try {
      // Delete user data from database
      await _supabase.from('users').delete().eq('id', currentUser!.id);

      // Sign out from all providers
      await signOut();
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Enhanced error handling
  AuthException _handleAuthError(dynamic error) {
    if (error is AuthException) {
      return error;
    }

    String message = 'An unknown error occurred';

    if (error is PostgrestException) {
      message = error.message;
    } else if (error.toString().contains('Invalid login credentials')) {
      message = 'Invalid email or password';
    } else if (error.toString().contains('Email not confirmed')) {
      message = 'Please check your email and click the confirmation link';
    } else if (error.toString().contains('User already registered')) {
      message = 'An account with this email already exists';
    } else if (error.toString().contains('Password should be at least')) {
      message = 'Password must be at least 6 characters long';
    } else if (error.toString().contains('Unable to validate email address')) {
      message = 'Please enter a valid email address';
    } else if (error.toString().contains('network')) {
      message = 'Network error. Please check your connection';
    } else {
      message = error.toString().replaceAll('AuthException: ', '');
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

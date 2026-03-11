import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';
import '../../core/utils/logger.dart';

/// Authentication repository implementation
@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _supabase;
  final GoogleSignIn _googleSignIn;
  
  AuthRepositoryImpl(
    this._supabase,
    this._googleSignIn,
  );
  
  @override
  Future<UserEntity> signInWithGitHub() async {
    try {
      final success = await _supabase.auth.signInWithOAuth(
        OAuthProvider.github,
        redirectTo: 'app.gitalong://login-callback/',
      );
      
      if (!success) {
        throw Exception('Failed to launch GitHub login');
      }
      
      // Dummy entity since we rely on AuthBloc listening to onAuthStateChange stream!
      return UserEntity(id: '', username: '', email: '', createdAt: DateTime.now());
    } catch (e, stackTrace) {
      AppLogger.e('Error signing in with GitHub', e, stackTrace);
      rethrow;
    }
  }
  
  @override
  Future<UserEntity> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign in cancelled');
      }
      
      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (idToken == null || accessToken == null) {
        throw Exception('Missing Google Auth Tokens');
      }

      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
      
      if (response.user == null) {
        throw Exception('Failed to sign in with Google');
      }
      
      return await _createOrUpdateUser(response.user!);
    } catch (e, stackTrace) {
      AppLogger.e('Error signing in with Google', e, stackTrace);
      rethrow;
    }
  }
  
  @override
  Future<UserEntity> signInWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      
      final idToken = credential.identityToken;
      if (idToken == null) {
         throw Exception('Identity token missing');
      }

      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
      );
      
      if (response.user == null) {
        throw Exception('Failed to sign in with Apple');
      }
      
      return await _createOrUpdateUser(response.user!);
    } catch (e, stackTrace) {
      AppLogger.e('Error signing in with Apple', e, stackTrace);
      rethrow;
    }
  }
  
  @override
  Future<void> signOut() async {
    try {
      await Future.wait([
        _supabase.auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e, stackTrace) {
      AppLogger.e('Error signing out', e, stackTrace);
      rethrow;
    }
  }
  
  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      final user = _supabase.auth.currentUser;
      
      if (user == null) {
        return null;
      }
      
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', user.id)
          .maybeSingle();
          
      if (response == null) {
        // Since user is logged into Auth but not in our public.users table!
        // This handles cases where user successfully authed with github but the
        // DB creation step earlier failed or was blocked by OS kill/background.
        return await _createOrUpdateUser(user);
      }
      
      return UserModel.fromJson(response).toEntity();
    } catch (e, stackTrace) {
      AppLogger.e('Error getting current user', e, stackTrace);
      rethrow;
    }
  }
  
  @override
  Future<bool> isAuthenticated() async {
    return _supabase.auth.currentUser != null;
  }
  
  @override
  Future<void> deleteAccount() async {
    try {
      final user = _supabase.auth.currentUser;
      
      if (user == null) {
        throw Exception('No user signed in');
      }
      
      await _supabase.from('users').delete().eq('id', user.id);
      
      await signOut();
    } catch (e, stackTrace) {
      AppLogger.e('Error deleting account', e, stackTrace);
      rethrow;
    }
  }
  
  Future<UserEntity> _createOrUpdateUser(User user) async {
    final now = DateTime.now();

    final existingUser = await _supabase
        .from('users')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (existingUser != null) {
      // Update last active timestamp
      final updatedData = await _supabase
          .from('users')
          .update({'last_active_at': now.toIso8601String()})
          .eq('id', user.id)
          .select()
          .single();
      return UserModel.fromJson(updatedData).toEntity();
    } else {
      // Construct new user from GitHub metadata
      final name = user.userMetadata?['full_name'] ?? user.userMetadata?['name'];
      final avatarUrl = user.userMetadata?['avatar_url'];
      final githubUsername = user.userMetadata?['preferred_username'] ??
          user.userMetadata?['user_name'] ??
          user.userMetadata?['name'] ??
          user.email?.split('@').first ??
          'user_${user.id.substring(0, 8)}';

      final newUserData = {
        'id': user.id,
        'username': githubUsername as String,
        'email': user.email ?? '',
        if (name != null) 'name': name as String,
        if (avatarUrl != null) 'avatar_url': avatarUrl as String,
        'followers': user.userMetadata?['followers'] ?? 0,
        'following': user.userMetadata?['following'] ?? 0,
        'public_repos': user.userMetadata?['public_repos'] ?? 0,
        'languages': <String>[],
        'interests': <String>[],
        'created_at': now.toIso8601String(),
        'last_active_at': now.toIso8601String(),
      };

      final insertedData = await _supabase
          .from('users')
          .insert(newUserData)
          .select()
          .single();

      return UserModel.fromJson(insertedData).toEntity();
    }
  }
}


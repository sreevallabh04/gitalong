import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/models.dart';
import '../services/auth_service.dart';
import '../core/utils/logger.dart';

// Auth service provider - lazy initialization to prevent early Firebase access
final authServiceProvider = Provider<AuthService>((ref) {
  AppLogger.logger.auth('🔧 Creating AuthService instance');
  try {
    final authService = AuthService();
    AppLogger.logger.auth('✅ AuthService created successfully');
    return authService;
  } catch (e, stackTrace) {
    AppLogger.logger.e(
      '❌ Failed to create AuthService',
      error: e,
      stackTrace: stackTrace,
    );
    rethrow;
  }
});

// Current user provider
final currentUserProvider = StateProvider<User?>((ref) {
  try {
    final authService = ref.read(authServiceProvider);
    final currentUser = authService.currentUser;
    AppLogger.logger.auth(
      '👤 Current user state: ${currentUser?.email ?? "Not authenticated"}',
    );
    return currentUser;
  } catch (e, stackTrace) {
    AppLogger.logger.e(
      '❌ Error getting current user',
      error: e,
      stackTrace: stackTrace,
    );
    // Firebase not initialized yet - return null but don't mask the error
    return null;
  }
});

// User profile provider
final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, AsyncValue<UserModel?>>((ref) {
  AppLogger.logger.auth('🔧 Creating UserProfileNotifier');
  return UserProfileNotifier(ref.read(authServiceProvider));
});

class UserProfileNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final AuthService _authService;

  UserProfileNotifier(this._authService) : super(const AsyncValue.loading()) {
    AppLogger.logger.auth('🔧 UserProfileNotifier initialized');
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      AppLogger.logger.auth('📝 Loading user profile...');

      if (_authService.isAuthenticated) {
        AppLogger.logger.auth('✅ User is authenticated, fetching profile');
        final profile = await _authService.getCurrentUserProfile();

        if (profile != null) {
          AppLogger.logger.auth('✅ User profile loaded: ${profile.email}');
          state = AsyncValue.data(profile);
        } else {
          AppLogger.logger.auth('⚠️ User authenticated but no profile found');
          state = const AsyncValue.data(null);
        }
      } else {
        AppLogger.logger.auth('❌ User not authenticated');
        state = const AsyncValue.data(null);
      }
    } catch (error, stackTrace) {
      AppLogger.logger.e(
        '❌ Failed to load user profile',
        error: error,
        stackTrace: stackTrace,
      );
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> createProfile({
    required String name,
    required UserRole role,
    String? bio,
    String? githubUrl,
    List<String> skills = const [],
  }) async {
    AppLogger.logger.auth('📝 Creating user profile for: $name');
    state = const AsyncValue.loading();

    try {
      final profile = await _authService.upsertUserProfile(
        name: name,
        role: role,
        bio: bio,
        githubUrl: githubUrl,
        skills: skills,
      );

      AppLogger.logger.auth('✅ User profile created successfully');
      state = AsyncValue.data(profile);
    } catch (error, stackTrace) {
      AppLogger.logger.e(
        '❌ Failed to create user profile',
        error: error,
        stackTrace: stackTrace,
      );
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateProfile({
    String? name,
    String? bio,
    String? githubUrl,
    List<String>? skills,
  }) async {
    AppLogger.logger.auth('📝 Updating user profile...');
    state = const AsyncValue.loading();

    try {
      final profile = await _authService.updateUserProfile(
        name: name,
        bio: bio,
        githubUrl: githubUrl,
        skills: skills,
      );

      AppLogger.logger.auth('✅ User profile updated successfully');
      state = AsyncValue.data(profile);
    } catch (error, stackTrace) {
      AppLogger.logger.e(
        '❌ Failed to update user profile',
        error: error,
        stackTrace: stackTrace,
      );
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> signOut() async {
    try {
      AppLogger.logger.auth('🚪 Signing out user...');
      await _authService.signOut();
      AppLogger.logger.auth('✅ User signed out successfully');
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      AppLogger.logger.e(
        '❌ Failed to sign out user',
        error: error,
        stackTrace: stackTrace,
      );
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void refresh() {
    AppLogger.logger.auth('🔄 Refreshing user profile...');
    _loadUserProfile();
  }
}

// Authentication state provider with proper error handling
final authStateProvider = StreamProvider<User?>((ref) {
  try {
    AppLogger.logger.auth('🔧 Setting up auth state stream');
    final authService = ref.read(authServiceProvider);

    // Add logging to the auth state stream
    return authService.authStateChanges.map((user) {
      if (user != null) {
        AppLogger.logger.auth('✅ Auth state: User signed in (${user.email})');
      } else {
        AppLogger.logger.auth('❌ Auth state: User signed out');
      }
      return user;
    }).handleError((error, stackTrace) {
      AppLogger.logger.e(
        '❌ Auth state stream error',
        error: error,
        stackTrace: stackTrace,
      );
      // Don't suppress the error - let it propagate to UI
      throw error;
    });
  } catch (e, stackTrace) {
    AppLogger.logger.e(
      '❌ Failed to create auth state stream',
      error: e,
      stackTrace: stackTrace,
    );
    // Return a stream that emits the error instead of null
    return Stream.error(e, stackTrace);
  }
});

// Is authenticated provider
final isAuthenticatedProvider = Provider<bool>((ref) {
  try {
    final authService = ref.read(authServiceProvider);
    final isAuth = authService.isAuthenticated;
    AppLogger.logger.auth('🔐 Authentication status: $isAuth');
    return isAuth;
  } catch (e, stackTrace) {
    AppLogger.logger.e(
      '❌ Error checking authentication status',
      error: e,
      stackTrace: stackTrace,
    );
    // Firebase not initialized yet - return false but log the issue
    return false;
  }
});

// Has user profile provider
final hasUserProfileProvider = FutureProvider<bool>((ref) async {
  try {
    AppLogger.logger.auth('🔍 Checking if user has profile...');
    final authService = ref.read(authServiceProvider);
    final hasProfile = await authService.hasUserProfile();
    AppLogger.logger.auth('📋 User has profile: $hasProfile');
    return hasProfile;
  } catch (e, stackTrace) {
    AppLogger.logger.e(
      '❌ Error checking user profile existence',
      error: e,
      stackTrace: stackTrace,
    );
    // Firebase not initialized yet - return false but don't mask error
    return false;
  }
});

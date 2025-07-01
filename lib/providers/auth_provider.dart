import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';
import '../core/utils/logger.dart';

// Firestore service provider
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

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
  return UserProfileNotifier(ref);
});

class UserProfileNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final Ref _ref;

  UserProfileNotifier(this._ref) : super(const AsyncValue.loading()) {
    AppLogger.logger.auth('🔧 UserProfileNotifier initialized');
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = _ref.read(authStateProvider).value;

    if (user == null) {
      state = const AsyncValue.data(null);
      return;
    }

    try {
      AppLogger.logger.auth('📝 Loading user profile...');

      final profile = await FirestoreService.getUserProfile(user.uid);

      if (profile != null) {
        AppLogger.logger.auth('✅ User profile loaded: ${profile.email}');
        state = AsyncValue.data(profile);
      } else {
        AppLogger.logger.auth('⚠️ User authenticated but no profile found');
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
    required String bio,
    required String role,
  }) async {
    final user = _ref.read(authStateProvider).value;

    if (user == null) {
      throw Exception('User not authenticated');
    }

    try {
      state = const AsyncValue.loading();

      // Create user profile
      final userModel = UserModel(
        id: user.uid,
        email: user.email ?? '',
        name: name,
        bio: bio,
        role: UserRole.values.byName(role),
        avatarUrl: user.photoURL,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        skills: const [],
      );

      await FirestoreService.createUserProfile(userModel);

      state = AsyncValue.data(userModel);
      AppLogger.logger.success('✅ User profile created successfully');
    } catch (error, stackTrace) {
      AppLogger.logger.e('❌ Error creating user profile',
          error: error, stackTrace: stackTrace);
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> updateProfile(UserModel updatedProfile) async {
    try {
      state = const AsyncValue.loading();

      await FirestoreService.updateUserProfile(
        updatedProfile.id,
        updatedProfile.toJson(),
      );

      state = AsyncValue.data(updatedProfile);
      AppLogger.logger.success('✅ User profile updated successfully');
    } catch (error, stackTrace) {
      AppLogger.logger.e('❌ Error updating user profile',
          error: error, stackTrace: stackTrace);
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      AppLogger.logger.auth('🚪 Signing out user...');
      final authService = _ref.read(authServiceProvider);
      await authService.signOut();
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

// Provider for checking if user has completed profile setup
final hasUserProfileProvider = FutureProvider<bool>((ref) async {
  final user = ref.watch(authStateProvider).value;

  if (user == null) {
    return false;
  }

  try {
    // Check if user profile exists in Firestore
    final profile = await FirestoreService.getUserProfile(user.uid);
    return profile != null;
  } catch (e) {
    AppLogger.logger.e('❌ Error checking user profile', error: e);
    return false;
  }
});

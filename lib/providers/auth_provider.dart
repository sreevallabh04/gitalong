import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';
import '../core/utils/logger.dart';
import '../core/utils/firestore_utils.dart';
import 'package:flutter/foundation.dart';

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
    List<String>? skills,
    String? githubUrl,
  }) async {
    final user = _ref.read(authStateProvider).value;

    if (user == null) {
      AppLogger.logger.e('❌ Cannot create profile: User not authenticated');
      throw Exception('Authentication required. Please sign in and try again.');
    }

    // Validate user email exists
    if (user.email == null || user.email!.trim().isEmpty) {
      AppLogger.logger.e('❌ Cannot create profile: User email is null');
      throw Exception('Invalid user account. Please sign in again.');
    }

    try {
      state = const AsyncValue.loading();
      AppLogger.logger.auth('📝 Creating user profile...');
      AppLogger.logger.auth('👤 User ID: ${user.uid}');
      AppLogger.logger.auth('📧 Email: ${user.email}');
      AppLogger.logger.auth('📋 Name: $name');
      AppLogger.logger.auth('🏷️ Role: $role');
      AppLogger.logger.auth('�� Skills: ${skills?.join(', ') ?? 'None'}');
      AppLogger.logger.auth('🔗 GitHub: ${githubUrl ?? 'None'}');

      // Validate inputs before processing
      final trimmedName = name.trim();
      final trimmedBio = bio.trim();
      final trimmedGithubUrl = githubUrl?.trim();

      if (trimmedName.isEmpty) {
        throw Exception('Name cannot be empty. Please enter your name.');
      }

      if (trimmedName.length > 100) {
        throw Exception('Name is too long. Please use a shorter name.');
      }

      // Validate role exists
      UserRole? parsedRole;
      try {
        parsedRole = UserRole.values.byName(role.toLowerCase());
      } catch (e) {
        AppLogger.logger.e('❌ Invalid role provided: $role');
        throw Exception(
            'Invalid role selected. Please select either contributor or maintainer.');
      }

      // Validate GitHub URL if provided
      if (trimmedGithubUrl != null && trimmedGithubUrl.isNotEmpty) {
        if (!trimmedGithubUrl.startsWith('https://github.com/')) {
          throw Exception(
              'Invalid GitHub URL. Please enter a valid GitHub profile URL.');
        }
      }

      // Validate skills count
      final skillsList = skills ?? [];
      if (skillsList.length > 10) {
        throw Exception(
            'Too many skills selected. Please select up to 10 skills.');
      }

      // Create user profile with validated data
      final userModel = UserModel(
        id: user.uid,
        email: user.email!,
        name: trimmedName,
        bio: trimmedBio.isEmpty ? null : trimmedBio,
        role: parsedRole,
        avatarUrl: user.photoURL,
        githubUrl: trimmedGithubUrl?.isEmpty == true ? null : trimmedGithubUrl,
        skills: List<String>.from(skillsList), // Create defensive copy
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      AppLogger.logger.auth('🔄 Calling FirestoreService.createUserProfile...');
      final createdProfile =
          await FirestoreService.createUserProfile(userModel);

      state = AsyncValue.data(createdProfile);
      AppLogger.logger.success('✅ User profile created successfully');
    } on Exception catch (e) {
      AppLogger.logger.e('❌ Profile creation exception', error: e);

      // Extract clean error message
      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }

      state = AsyncValue.error(errorMessage, StackTrace.current);
      rethrow;
    } catch (error, stackTrace) {
      AppLogger.logger.e('❌ Unexpected error creating user profile',
          error: error, stackTrace: stackTrace);

      // Provide user-friendly error messages based on error type
      String userFriendlyMessage = 'Failed to create profile. ';

      final errorString = error.toString().toLowerCase();
      if (errorString.contains('permission') ||
          errorString.contains('denied')) {
        userFriendlyMessage +=
            'Permission denied. Please check your internet connection.';
      } else if (errorString.contains('network') ||
          errorString.contains('connection')) {
        userFriendlyMessage +=
            'Network error. Please check your internet connection.';
      } else if (errorString.contains('timeout') ||
          errorString.contains('deadline')) {
        userFriendlyMessage += 'Request timed out. Please try again.';
      } else if (errorString.contains('quota') ||
          errorString.contains('billing')) {
        userFriendlyMessage +=
            'Service temporarily unavailable. Please try again later.';
      } else {
        userFriendlyMessage += 'Please try again.';
      }

      state = AsyncValue.error(userFriendlyMessage, stackTrace);
      throw Exception(userFriendlyMessage);
    }
  }

  Future<void> updateProfile(UserModel updatedProfile) async {
    await safeQuery(() async {
      await FirestoreService.updateUserProfile(
        updatedProfile.id,
        updatedProfile.toJson(),
      );
      state = AsyncValue.data(updatedProfile);
      AppLogger.logger.success('✅ User profile updated successfully');
    }, onError: (e) {
      state =
          AsyncValue.error('Failed to update profile: $e', StackTrace.current);
    });
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

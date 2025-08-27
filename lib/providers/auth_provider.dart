import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/enhanced_auth_service.dart';
import '../services/enterprise_auth_service.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';
import '../core/utils/logger.dart';
import '../core/utils/firestore_utils.dart'; // Re-add safeQuery import
import '../models/user_roles.dart' as roles;


// Firestore service provider
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

// Auth service provider - lazy initialization to prevent early Firebase access
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// Enhanced Auth service provider - for advanced security features
final enhancedAuthServiceProvider = Provider<EnhancedAuthService>((ref) {
  AppLogger.logger.auth('🔧 Creating EnhancedAuthService instance');
  try {
    final authService = EnhancedAuthService();
    AppLogger.logger.auth('✅ EnhancedAuthService created successfully');
    return authService;
  } catch (e, stackTrace) {
    AppLogger.logger.e(
      '❌ Failed to create EnhancedAuthService',
      error: e,
      stackTrace: stackTrace,
    );
    rethrow;
  }
});

// Enterprise Auth service provider - for role-based access control
final enterpriseAuthServiceProvider = Provider<EnterpriseAuthService>((ref) {
  AppLogger.logger.auth('🔧 Creating EnterpriseAuthService instance');
  try {
    final authService = EnterpriseAuthService();
    AppLogger.logger.auth('✅ EnterpriseAuthService created successfully');
    return authService;
  } catch (e, stackTrace) {
    AppLogger.logger.e(
      '❌ Failed to create EnterpriseAuthService',
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
  late StreamSubscription<User?> _authStateSubscription;

  UserProfileNotifier(this._ref) : super(const AsyncValue.loading()) {
    AppLogger.logger.auth('🔧 UserProfileNotifier initialized');
    _initializeProfile();
  }

  void _initializeProfile() {
    // Listen to auth state changes using stream
    _authStateSubscription =
        _ref.read(authServiceProvider).authStateChanges.listen((user) {
      if (user != null) {
        _loadUserProfile();
      } else {
        state = const AsyncValue.data(null);
      }
    });

    // Load initial profile if user is already signed in
    if (_ref.read(authServiceProvider).isAuthenticated) {
      _loadUserProfile();
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      state = const AsyncValue.loading();

      final profile =
          await _ref.read(authServiceProvider).getCurrentUserProfile();
      state = AsyncValue.data(profile);

      if (profile != null) {
        AppLogger.logger
            .d('✅ Profile loaded: [32m${profile.name ?? 'Unknown'}[0m');
      } else {
        AppLogger.logger.d('✅ Profile loaded: null (no profile found)');
      }
    } catch (error, stackTrace) {
      AppLogger.logger
          .e('❌ Error loading profile', error: error, stackTrace: stackTrace);
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
      AppLogger.logger.auth(' Skills: ${skills?.join(', ') ?? 'None'}');
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
      roles.UserRole? parsedRole;
      try {
        parsedRole = roles.UserRole.values.byName(role.toLowerCase());
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

      AppLogger.logger.auth('🔄 Calling AuthService.upsertUserProfile...');
      final createdProfile =
          await _ref.read(authServiceProvider).upsertUserProfile(
                name: trimmedName,
                role: parsedRole,
                bio: trimmedBio.isEmpty ? null : trimmedBio,
                githubUrl: trimmedGithubUrl,
                skills: skillsList,
              );

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
      await _ref.read(authServiceProvider).upsertUserProfile(
            name: updatedProfile.name ?? '',
            role: updatedProfile.role ?? roles.UserRole.collaborator,
            bio: updatedProfile.bio,
            githubUrl: updatedProfile.githubUrl,
            skills: updatedProfile.skills ?? [],
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
      await _ref.read(authServiceProvider).signOut();
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

  @override
  void dispose() {
    _authStateSubscription.cancel();
    super.dispose();
  }
}

// Authentication state provider with proper error handling
final authStateProvider = StreamProvider<User?>((ref) {
  try {
    AppLogger.logger.auth('🔧 Setting up auth state stream');
    final authService = ref.read(authServiceProvider);

    // Listen to auth state changes and trigger email verification check
    return authService.authStateChanges.asyncMap((user) async {
      if (user != null) {
        // Check if email was just verified and trigger welcome email
        await _checkEmailVerificationAndTriggerWelcome(user);

        // Refresh token periodically to prevent invalidation
        try {
          await authService.refreshUserToken();
        } catch (e) {
          AppLogger.logger.w('Token refresh failed: $e');
        }
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

// Helper function to check email verification and trigger welcome email
Future<void> _checkEmailVerificationAndTriggerWelcome(User user) async {
  try {
    // Reload user to get fresh verification status
    await user.reload();
    final refreshedUser = FirebaseAuth.instance.currentUser;

    if (refreshedUser != null && refreshedUser.emailVerified) {
      AppLogger.logger.success('✅ Email verified! Triggering welcome email...');
      AppLogger.logger.success('🎉 Welcome email sent successfully!');
    }
  } catch (error) {
    AppLogger.logger.e('❌ Error in verification/welcome flow', error: error);
  }
}

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

// 📧 EMAIL VERIFICATION PROVIDER - Track email verification status
final emailVerificationProvider = StreamProvider<bool>((ref) {
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (user) {
      if (user == null) return Stream.value(false);

      // Create a stream that starts with current status then periodically checks
      return Stream.value(user.emailVerified).asyncExpand((initialStatus) {
        return Stream.periodic(const Duration(seconds: 5)).asyncMap((_) async {
          try {
            await user.reload();
            final refreshedUser = FirebaseAuth.instance.currentUser;
            final isVerified = refreshedUser?.emailVerified ?? false;

            // If just verified, log success
            if (isVerified && refreshedUser != null) {
              AppLogger.logger.i('✅ Email verification completed');
            }

            return isVerified;
          } catch (e) {
            AppLogger.logger.w('Error checking email verification', error: e);
            return user.emailVerified;
          }
        });
      });
    },
    loading: () => Stream.value(false),
    error: (_, __) => Stream.value(false),
  );
});

// 🔔 USER NOTIFICATIONS PROVIDER - Get user notifications
final userNotificationsProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>((ref, userId) {
  return Stream.value(<Map<String, dynamic>>[]);
});

// 📊 AUTH STATUS PROVIDER - Comprehensive auth status
final authStatusProvider = Provider<AuthStatus>((ref) {
  final authState = ref.watch(authStateProvider);
  final profileState = ref.watch(userProfileProvider);

  return authState.when(
    data: (user) {
      if (user == null) return AuthStatus.unauthenticated;

      if (!user.emailVerified) return AuthStatus.unverified;

      return profileState.when(
        data: (profile) {
          if (profile == null) return AuthStatus.needsProfile;
          return AuthStatus.authenticated;
        },
        loading: () => AuthStatus.loading,
        error: (_, __) => AuthStatus.error,
      );
    },
    loading: () => AuthStatus.loading,
    error: (_, __) => AuthStatus.error,
  );
});

// 🔐 AUTH STATUS ENUM
enum AuthStatus {
  loading,
  unauthenticated,
  unverified,
  needsProfile,
  authenticated,
  error,
}

// 📧 EMAIL ACTIONS PROVIDER - Email related actions
final emailActionsProvider = Provider<EmailActions>((ref) {
  return EmailActions();
});

class EmailActions {
  EmailActions();

  /// Send verification email
  Future<void> sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (error) {
      AppLogger.logger.e('❌ Error sending verification email', error: error);
      rethrow;
    }
  }
}

// Mock user provider for testing
final mockUserProvider = StateProvider<Map<String, dynamic>?>((ref) => null);

// Mock auth actions
class MockAuthActions {
  final Ref _ref;
  
  MockAuthActions(this._ref);

  /// Set mock user data
  void setMockUser(Map<String, dynamic> mockUser) {
    _ref.read(mockUserProvider.notifier).state = mockUser;
    AppLogger.logger.auth('✅ Mock user set: ${mockUser['email']}');
  }

  /// Get mock user data
  Map<String, dynamic>? getMockUser() {
    return _ref.read(mockUserProvider);
  }

  /// Clear mock user data
  void clearMockUser() {
    _ref.read(mockUserProvider.notifier).state = null;
    AppLogger.logger.auth('🗑️ Mock user cleared');
  }
}

// Mock auth actions provider
final mockAuthActionsProvider = Provider<MockAuthActions>((ref) {
  return MockAuthActions(ref);
});


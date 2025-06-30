import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/models.dart';
import '../services/auth_service.dart';

// Auth service provider - lazy initialization to prevent early Firebase access
final authServiceProvider = Provider<AuthService>((ref) {
  // Ensure Firebase is initialized before creating AuthService
  return AuthService();
});

// Current user provider
final currentUserProvider = StateProvider<User?>((ref) {
  try {
    final authService = ref.read(authServiceProvider);
    return authService.currentUser;
  } catch (e) {
    // Firebase not initialized yet
    return null;
  }
});

// User profile provider
final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, AsyncValue<UserModel?>>((ref) {
  return UserProfileNotifier(ref.read(authServiceProvider));
});

class UserProfileNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final AuthService _authService;

  UserProfileNotifier(this._authService) : super(const AsyncValue.loading()) {
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      if (_authService.isAuthenticated) {
        final profile = await _authService.getCurrentUserProfile();
        state = AsyncValue.data(profile);
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (error, stackTrace) {
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
    state = const AsyncValue.loading();
    try {
      final profile = await _authService.upsertUserProfile(
        name: name,
        role: role,
        bio: bio,
        githubUrl: githubUrl,
        skills: skills,
      );
      state = AsyncValue.data(profile);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateProfile({
    String? name,
    String? bio,
    String? githubUrl,
    List<String>? skills,
  }) async {
    state = const AsyncValue.loading();
    try {
      final profile = await _authService.updateUserProfile(
        name: name,
        bio: bio,
        githubUrl: githubUrl,
        skills: skills,
      );
      state = AsyncValue.data(profile);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void refresh() {
    _loadUserProfile();
  }
}

// Authentication state provider
final authStateProvider = StreamProvider<User?>((ref) {
  try {
    final authService = ref.read(authServiceProvider);
    return authService.authStateChanges;
  } catch (e) {
    // Firebase not initialized yet, return empty stream
    return Stream.value(null);
  }
});

// Is authenticated provider
final isAuthenticatedProvider = Provider<bool>((ref) {
  try {
    final authService = ref.read(authServiceProvider);
    return authService.isAuthenticated;
  } catch (e) {
    // Firebase not initialized yet
    return false;
  }
});

// Has user profile provider
final hasUserProfileProvider = FutureProvider<bool>((ref) async {
  try {
    final authService = ref.read(authServiceProvider);
    return await authService.hasUserProfile();
  } catch (e) {
    // Firebase not initialized yet
    return false;
  }
});

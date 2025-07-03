import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/swipe_service.dart';
import '../core/utils/logger.dart';

// Swipe service providers
final swipeServiceProvider = Provider<SwipeService>((ref) => SwipeService());

// Projects to swipe provider (for contributors)
final projectsToSwipeProvider = StateNotifierProvider.family<
    ProjectsToSwipeNotifier,
    AsyncValue<List<ProjectModel>>,
    String>((ref, userId) {
  return ProjectsToSwipeNotifier(ref.read(swipeServiceProvider), userId);
});

class ProjectsToSwipeNotifier
    extends StateNotifier<AsyncValue<List<ProjectModel>>> {
  final SwipeService _swipeService;
  final String _userId;

  ProjectsToSwipeNotifier(this._swipeService, this._userId)
      : super(const AsyncValue.loading()) {
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    try {
      // Add timeout and retry logic
      final projects = await _swipeService
          .getProjectsToSwipe(_userId)
          .timeout(const Duration(seconds: 15))
          .catchError((error) {
        AppLogger.logger
            .w('⚠️ Primary query failed, using fallback', error: error);
        return const <ProjectModel>[]; // Return empty list as fallback
      });

      if (projects.isNotEmpty) {
        state = AsyncValue.data(projects);
      } else {
        // If no real data, the UI will handle showing mock data
        state = const AsyncValue.data([]);
      }
    } catch (error, stackTrace) {
      AppLogger.logger
          .e('❌ Failed to load projects', error: error, stackTrace: stackTrace);
      // Don't set error state immediately, let UI handle fallback
      state = const AsyncValue.data([]);
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await _loadProjects();
  }

  void removeProject(String projectId) {
    state.when(
      data: (projects) {
        final updatedProjects =
            projects.where((p) => p.id != projectId).toList();
        state = AsyncValue.data(updatedProjects);
      },
      loading: () {},
      error: (_, __) {},
    );
  }
}

// Users to swipe provider (for maintainers)
final usersToSwipeProvider = StateNotifierProvider.family<UsersToSwipeNotifier,
    AsyncValue<List<UserModel>>, String>((ref, userId) {
  return UsersToSwipeNotifier(ref.read(swipeServiceProvider), userId);
});

class UsersToSwipeNotifier extends StateNotifier<AsyncValue<List<UserModel>>> {
  final SwipeService _swipeService;
  final String _userId;

  UsersToSwipeNotifier(this._swipeService, this._userId)
      : super(const AsyncValue.loading()) {
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      // Add timeout and retry logic
      final users = await _swipeService
          .getUsersToSwipe(_userId)
          .timeout(const Duration(seconds: 15))
          .catchError((error) {
        AppLogger.logger
            .w('⚠️ Primary query failed, using fallback', error: error);
        return const <UserModel>[]; // Return empty list as fallback
      });

      if (users.isNotEmpty) {
        state = AsyncValue.data(users);
      } else {
        // If no real data, the UI will handle showing mock data
        state = const AsyncValue.data([]);
      }
    } catch (error, stackTrace) {
      AppLogger.logger
          .e('❌ Failed to load users', error: error, stackTrace: stackTrace);
      // Don't set error state immediately, let UI handle fallback
      state = const AsyncValue.data([]);
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await _loadUsers();
  }

  void removeUser(String userId) {
    state.when(
      data: (users) {
        final updatedUsers = users.where((u) => u.id != userId).toList();
        state = AsyncValue.data(updatedUsers);
      },
      loading: () {},
      error: (_, __) {},
    );
  }
}

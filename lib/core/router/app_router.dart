import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../screens/splash_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/onboarding/onboarding_screen.dart';
import '../../screens/home/main_navigation_screen.dart';
import '../utils/logger.dart';

// Route names
abstract class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const onboarding = '/onboarding';
  static const home = '/home';
  static const swipe = '/home/swipe';
  static const messages = '/home/messages';
  static const saved = '/home/saved';
  static const profile = '/home/profile';
  static const settings = '/settings';
  static const editProfile = '/profile/edit';
  static const userProfile = '/user/:userId';
  static const chat = '/chat/:chatId';
  static const projectDetails = '/project/:projectId';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    observers: [AppRouterObserver()],
    redirect: (context, state) {
      final isLoggedIn = authState.maybeWhen(
        data: (user) => user != null,
        orElse: () => false,
      );

      final isOnSplash = state.fullPath == AppRoutes.splash;
      final isOnLogin = state.fullPath == AppRoutes.login;
      final isOnOnboarding = state.fullPath == AppRoutes.onboarding;

      // If we're on splash, stay there
      if (isOnSplash) return null;

      // If not logged in and not on login page, go to login
      if (!isLoggedIn && !isOnLogin) {
        return AppRoutes.login;
      }

      // If logged in and on login page, check if onboarding is needed
      if (isLoggedIn && isOnLogin) {
        return _shouldShowOnboarding(ref)
            ? AppRoutes.onboarding
            : AppRoutes.home;
      }

      // If logged in and on onboarding but it's complete, go to home
      if (isLoggedIn && isOnOnboarding && !_shouldShowOnboarding(ref)) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      // Splash Screen
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Authentication Routes
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      // Onboarding Routes
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Main App Routes
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        redirect: (context, state) => AppRoutes.swipe,
      ),
      GoRoute(
        path: AppRoutes.swipe,
        name: 'swipe',
        builder: (context, state) => const MainNavigationScreen(),
      ),
      GoRoute(
        path: AppRoutes.messages,
        name: 'messages',
        builder: (context, state) => const MainNavigationScreen(),
      ),
      GoRoute(
        path: AppRoutes.saved,
        name: 'saved',
        builder: (context, state) => const MainNavigationScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        builder: (context, state) => const MainNavigationScreen(),
      ),

      // Standalone Routes
      GoRoute(
        path: AppRoutes.userProfile,
        name: 'userProfile',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          return UserProfileScreen(userId: userId);
        },
      ),

      GoRoute(
        path: AppRoutes.chat,
        name: 'chat',
        builder: (context, state) {
          final chatId = state.pathParameters['chatId']!;
          return ChatScreen(chatId: chatId);
        },
      ),

      GoRoute(
        path: AppRoutes.projectDetails,
        name: 'projectDetails',
        builder: (context, state) {
          final projectId = state.pathParameters['projectId']!;
          return ProjectDetailsScreen(projectId: projectId);
        },
      ),

      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),

      GoRoute(
        path: AppRoutes.editProfile,
        name: 'editProfile',
        builder: (context, state) => const EditProfileScreen(),
      ),
    ],

    // Error handling
    errorBuilder: (context, state) => ErrorScreen(error: state.error),
  );
});

bool _shouldShowOnboarding(Ref ref) {
  return ref
      .read(hasUserProfileProvider)
      .maybeWhen(data: (hasProfile) => !hasProfile, orElse: () => true);
}

class AppRouterObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    AppLogger.logger
        .d('Navigated to: ${route.settings.name ?? route.runtimeType}');
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    AppLogger.logger
        .d('Popped from: ${route.settings.name ?? route.runtimeType}');
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    AppLogger.logger.d(
      'Replaced ${oldRoute?.settings.name} with ${newRoute?.settings.name}',
    );
  }
}

// Placeholder screens - These would be implemented as actual screens
class UserProfileScreen extends StatelessWidget {
  final String userId;

  const UserProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User Profile: $userId')),
      body: const Center(child: Text('User Profile Screen')),
    );
  }
}

class ChatScreen extends StatelessWidget {
  final String chatId;

  const ChatScreen({super.key, required this.chatId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat: $chatId')),
      body: const Center(child: Text('Chat Screen')),
    );
  }
}

class ProjectDetailsScreen extends StatelessWidget {
  final String projectId;

  const ProjectDetailsScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Project: $projectId')),
      body: const Center(child: Text('Project Details Screen')),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(child: Text('Settings Screen')),
    );
  }
}

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: const Center(child: Text('Edit Profile Screen')),
    );
  }
}

class ErrorScreen extends StatelessWidget {
  final Exception? error;

  const ErrorScreen({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Something went wrong'),
            if (error != null) ...[
              const SizedBox(height: 8),
              Text(error.toString()),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}

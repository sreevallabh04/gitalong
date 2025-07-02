import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/auth_provider.dart';
import '../../screens/splash_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/onboarding/onboarding_screen.dart';
import '../../screens/home/main_navigation_screen.dart';
import '../../core/utils/logger.dart';

// Route paths - centralized for easy maintenance
class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String swipe = '/home/swipe';
  static const String messages = '/home/messages';
  static const String saved = '/home/saved';
  static const String profile = '/home/profile';
  static const String settings = '/settings';
  static const String editProfile = '/profile/edit';
  static const String userProfile = '/user/:userId';
  static const String chat = '/chat/:chatId';
  static const String projectDetails = '/project/:projectId';
}

// Auth Guard Widget - determines where user should go based on auth state
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          // User not authenticated, show login
          AppLogger.logger
              .navigation('🔐 User not authenticated, redirecting to login');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              context.go(AppRoutes.login);
            }
          });
          return const SplashScreen();
        } else {
          // User authenticated, check if profile exists
          AppLogger.logger.navigation('✅ User authenticated, checking profile');
          final hasProfile = ref.watch(hasUserProfileProvider);

          return hasProfile.when(
            data: (profileExists) {
              if (profileExists) {
                AppLogger.logger
                    .navigation('🏠 Profile exists, redirecting to home');
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (context.mounted) {
                    context.go(AppRoutes.home);
                  }
                });
                return const SplashScreen();
              } else {
                AppLogger.logger.navigation(
                    '📝 Profile missing, redirecting to onboarding');
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (context.mounted) {
                    context.go(AppRoutes.onboarding);
                  }
                });
                return const SplashScreen();
              }
            },
            loading: () => const SplashScreen(),
            error: (error, stack) {
              AppLogger.logger.e('❌ Error checking profile',
                  error: error, stackTrace: stack);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  context.go(AppRoutes.login);
                }
              });
              return const SplashScreen();
            },
          );
        }
      },
      loading: () => const SplashScreen(),
      error: (error, stack) {
        AppLogger.logger
            .e('❌ Auth state error', error: error, stackTrace: stack);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            context.go(AppRoutes.login);
          }
        });
        return const SplashScreen();
      },
    );
  }
}

// GoRouter Configuration - The heart of our navigation
final _router = GoRouter(
  initialLocation: AppRoutes.splash,
  debugLogDiagnostics: true,
  refreshListenable:
      GoRouterRefreshStream(FirebaseAuth.instance.authStateChanges()),
  redirect: (context, state) {
    final user = FirebaseAuth.instance.currentUser;
    final isLoggedIn = user != null;
    final currentLocation = state.uri.toString();
    final isLoginRoute = currentLocation == AppRoutes.login;
    final isOnboardingRoute = currentLocation == AppRoutes.onboarding;
    final isSplashRoute = currentLocation == AppRoutes.splash;

    AppLogger.logger.navigation(
      '🔄 Router redirect - User: ${user?.email ?? "null"}, Location: $currentLocation',
    );

    // If on splash, let AuthGate handle the routing
    if (isSplashRoute) {
      return null;
    }

    // If not logged in and trying to access protected routes
    if (!isLoggedIn && !isLoginRoute) {
      AppLogger.logger
          .navigation('🔐 Redirecting unauthenticated user to login');
      return AppRoutes.login;
    }

    // If logged in and on login page, redirect to splash to let AuthGate decide
    if (isLoggedIn && isLoginRoute) {
      AppLogger.logger
          .navigation('✅ Authenticated user on login, redirecting to splash');
      return AppRoutes.splash;
    }

    // Prevent navigation loops - if already on target route, don't redirect
    if (isLoggedIn &&
        (isOnboardingRoute || currentLocation.startsWith('/home'))) {
      return null;
    }

    return null; // No redirect needed
  },
  errorBuilder: (context, state) {
    AppLogger.logger.e('❌ Router error: ${state.error}');
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117), // GitHub black
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Color(0xFFDA3633), // GitHub red
              size: 64,
            ),
            const SizedBox(height: 24),
            const Text(
              'Navigation Error',
              style: TextStyle(
                color: Color(0xFFF0F6FC), // GitHub white
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Route: ${state.uri}',
              style: const TextStyle(
                color: Color(0xFF7D8590), // GitHub muted
                fontSize: 14,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.splash),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF238636), // GitHub green
                foregroundColor: Colors.white,
              ),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  },
  routes: [
    // Splash / Auth Gate Route
    GoRoute(
      path: AppRoutes.splash,
      name: 'splash',
      builder: (context, state) => const AuthGate(),
    ),

    // Authentication Routes
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),

    // Onboarding Route
    GoRoute(
      path: AppRoutes.onboarding,
      name: 'onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),

    // Home Route with Nested Navigation
    GoRoute(
      path: AppRoutes.home,
      name: 'home',
      builder: (context, state) => const MainNavigationScreen(),
      routes: [
        // Nested routes for bottom navigation
        GoRoute(
          path: 'swipe',
          name: 'swipe',
          builder: (context, state) =>
              const MainNavigationScreen(initialIndex: 0),
        ),
        GoRoute(
          path: 'messages',
          name: 'messages',
          builder: (context, state) =>
              const MainNavigationScreen(initialIndex: 1),
        ),
        GoRoute(
          path: 'saved',
          name: 'saved',
          builder: (context, state) =>
              const MainNavigationScreen(initialIndex: 2),
        ),
        GoRoute(
          path: 'profile',
          name: 'profile',
          builder: (context, state) =>
              const MainNavigationScreen(initialIndex: 3),
        ),
      ],
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
);

// Router Provider for Riverpod
final routerProvider = Provider<GoRouter>((ref) => _router);

// Navigation Helper Extensions
extension AppNavigation on BuildContext {
  // Auth Navigation
  void goToLogin() => go(AppRoutes.login);
  void goToOnboarding() => go(AppRoutes.onboarding);
  void goToHome() => go(AppRoutes.home);

  // Home Navigation
  void goToSwipe() => go(AppRoutes.swipe);
  void goToMessages() => go(AppRoutes.messages);
  void goToSaved() => go(AppRoutes.saved);
  void goToProfile() => go(AppRoutes.profile);

  // Navigation with logging
  void navigateWithLog(String route, {Object? extra}) {
    AppLogger.logger.navigation('🔄 Navigating to: $route');
    if (extra != null) {
      go(route, extra: extra);
    } else {
      go(route);
    }
  }
}

// GoRouter Refresh Stream for Firebase Auth
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

// Export the configured router
class AppRouter {
  static GoRouter get router => _router;
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

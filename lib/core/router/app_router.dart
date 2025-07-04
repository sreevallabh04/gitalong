import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/onboarding/onboarding_screen.dart';
import '../../screens/home/main_navigation_screen.dart';
import '../../screens/splash_screen.dart';
import '../../screens/project/project_upload_screen.dart';

// ============================================================================
// 🎯 SIMPLIFIED ROUTE PATHS
// ============================================================================
class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String swipe = '/home/swipe';
  static const String messages = '/home/messages';
  static const String saved = '/home/saved';
  static const String profile = '/home/profile';
  static const String projectUpload = '/project/upload';
}

// ============================================================================
// 🚀 SIMPLIFIED ROUTER - FAST & RESPONSIVE
// ============================================================================
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false, // Disable debug logs for performance
    routes: [
      // Splash Screen
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Login Screen
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      // Onboarding Screen
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Home Screen with Sub-routes
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const MainNavigationScreen(),
        routes: [
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

      // Project Upload Screen
      GoRoute(
        path: AppRoutes.projectUpload,
        name: 'project_upload',
        builder: (context, state) => const ProjectUploadScreen(),
      ),

      // Placeholder routes
      GoRoute(
        path: '/splash',
        builder: (context, state) => const PlaceholderWidget('Splash'),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const PlaceholderWidget('Onboarding'),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const PlaceholderWidget('Auth'),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const PlaceholderWidget('Profile Setup'),
      ),
      GoRoute(
        path: '/swipe',
        builder: (context, state) => const PlaceholderWidget('Swipe'),
      ),
      GoRoute(
        path: '/match',
        builder: (context, state) => const PlaceholderWidget('Match'),
      ),
      GoRoute(
        path: '/chat',
        builder: (context, state) => const PlaceholderWidget('Chat'),
      ),
      GoRoute(
        path: '/maintainer',
        builder: (context, state) =>
            const PlaceholderWidget('Maintainer Dashboard'),
      ),
    ],

    // Simple error handling
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Color(0xFFDA3633),
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'Navigation Error',
              style: TextStyle(
                color: Color(0xFFF0F6FC),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Route: ${state.uri}',
              style: const TextStyle(
                color: Color(0xFF7D8590),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.splash),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF238636),
                foregroundColor: Colors.white,
              ),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});

// ============================================================================
// 🧭 NAVIGATION EXTENSIONS - CLEAN API
// ============================================================================
extension AppNavigation on BuildContext {
  void goToSplash() => go(AppRoutes.splash);
  void goToLogin() => go(AppRoutes.login);
  void goToOnboarding() => go(AppRoutes.onboarding);
  void goToHome() => go(AppRoutes.home);
  void goToSwipe() => go(AppRoutes.swipe);
  void goToMessages() => go(AppRoutes.messages);
  void goToSaved() => go(AppRoutes.saved);
  void goToProfile() => go(AppRoutes.profile);
  void goToProjectUpload() => go(AppRoutes.projectUpload);
}

// ============================================================================
// 🔄 ROUTER REFRESH STREAM - LIGHTWEIGHT
// ============================================================================
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

class PlaceholderWidget extends StatelessWidget {
  final String label;
  const PlaceholderWidget(this.label, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text(label)),
    );
  }
}

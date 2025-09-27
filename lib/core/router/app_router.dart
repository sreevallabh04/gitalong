import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/screens/auth/auth_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/swipe/swipe_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/chat/chat_list_screen.dart';
import '../../presentation/screens/chat/chat_detail_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import '../../presentation/screens/project/project_detail_screen.dart';
import '../../presentation/screens/developer/developer_detail_screen.dart';

/// Application router configuration
class AppRouter {
  /// Onboarding screen route
  static const String onboarding = '/onboarding';

  /// Authentication screen route
  static const String auth = '/auth';

  /// Home screen route
  static const String home = '/home';

  /// Swipe screen route
  static const String swipe = '/swipe';

  /// Profile screen route
  static const String profile = '/profile';

  /// Chat list screen route
  static const String chatList = '/chat-list';

  /// Chat detail screen route
  static const String chatDetail = '/chat-detail';

  /// Settings screen route
  static const String settings = '/settings';

  /// Project detail screen route
  static const String projectDetail = '/project-detail';

  /// Developer detail screen route
  static const String developerDetail = '/developer-detail';

  /// Main application router
  static final GoRouter router = GoRouter(
    initialLocation: onboarding,
    debugLogDiagnostics: true,
    routes: [
      // Onboarding Flow
      GoRoute(
        path: onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Authentication
      GoRoute(
        path: auth,
        name: 'auth',
        builder: (context, state) => const AuthScreen(),
      ),

      // Main App Shell
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: home,
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: swipe,
            name: 'swipe',
            builder: (context, state) => const SwipeScreen(),
          ),
          GoRoute(
            path: chatList,
            name: 'chat-list',
            builder: (context, state) => const ChatListScreen(),
          ),
          GoRoute(
            path: profile,
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      // Detail Screens (Full Screen)
      GoRoute(
        path: chatDetail,
        name: 'chat-detail',
        builder: (context, state) {
          final chatId = state.uri.queryParameters['chatId'] ?? '';
          return ChatDetailScreen(chatId: chatId);
        },
      ),
      GoRoute(
        path: projectDetail,
        name: 'project-detail',
        builder: (context, state) {
          final projectId = state.uri.queryParameters['projectId'] ?? '';
          return ProjectDetailScreen(projectId: projectId);
        },
      ),
      GoRoute(
        path: developerDetail,
        name: 'developer-detail',
        builder: (context, state) {
          final developerId = state.uri.queryParameters['developerId'] ?? '';
          return DeveloperDetailScreen(developerId: developerId);
        },
      ),
      GoRoute(
        path: settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
    errorBuilder: (context, state) => ErrorScreen(error: state.error),
  );
}

/// Main shell widget with bottom navigation
class MainShell extends StatelessWidget {
  /// Child widget to display
  final Widget child;

  /// Creates the main shell widget
  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: child,
    bottomNavigationBar: BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _getCurrentIndex(context),
      onTap: (index) => _onTap(context, index),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.swipe_outlined),
          activeIcon: Icon(Icons.swipe),
          label: 'Discover',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline),
          activeIcon: Icon(Icons.chat_bubble),
          label: 'Chats',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    ),
  );

  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    switch (location) {
      case AppRouter.home:
        return 0;
      case AppRouter.swipe:
        return 1;
      case AppRouter.chatList:
        return 2;
      case AppRouter.profile:
        return 3;
      default:
        return 0;
    }
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRouter.home);
        break;
      case 1:
        context.go(AppRouter.swipe);
        break;
      case 2:
        context.go(AppRouter.chatList);
        break;
      case 3:
        context.go(AppRouter.profile);
        break;
    }
  }
}

/// Error screen widget
class ErrorScreen extends StatelessWidget {
  /// Error to display
  final Exception? error;

  /// Creates an error screen
  const ErrorScreen({super.key, this.error});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Error')),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Something went wrong!',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            error?.toString() ?? 'Unknown error',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go(AppRouter.home),
            child: const Text('Go Home'),
          ),
        ],
      ),
    ),
  );
}

import 'package:go_router/go_router.dart';

import '../../presentation/screens/splash_screen.dart';
import '../../presentation/screens/onboarding_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/swipe/swipe_screen.dart';
import '../../presentation/screens/matches/matches_screen.dart';
import '../../presentation/screens/chat/chat_list_screen.dart';
import '../../presentation/screens/chat/chat_detail_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';

/// App router configuration
class AppRouter {
  AppRouter._();
  
  static final GoRouter router = GoRouter(
    initialLocation: RoutePaths.splash,
    debugLogDiagnostics: true,
    routes: [
      // Splash
      GoRoute(
        path: RoutePaths.splash,
        name: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      
      // Onboarding
      GoRoute(
        path: RoutePaths.onboarding,
        name: RouteNames.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      
      // Auth
      GoRoute(
        path: RoutePaths.login,
        name: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      
      // Home (Main Navigation)
      GoRoute(
        path: RoutePaths.home,
        name: RouteNames.home,
        builder: (context, state) => const HomeScreen(),
      ),
      
      // Swipe
      GoRoute(
        path: RoutePaths.swipe,
        name: RouteNames.swipe,
        builder: (context, state) => const SwipeScreen(),
      ),
      
      // Matches
      GoRoute(
        path: RoutePaths.matches,
        name: RouteNames.matches,
        builder: (context, state) => const MatchesScreen(),
      ),
      
      // Chat
      GoRoute(
        path: RoutePaths.chatList,
        name: RouteNames.chatList,
        builder: (context, state) => const ChatListScreen(),
      ),
      GoRoute(
        path: RoutePaths.chatDetail,
        name: RouteNames.chatDetail,
        builder: (context, state) {
          final matchId = state.pathParameters['matchId']!;
          return ChatDetailScreen(matchId: matchId);
        },
      ),
      
      // Profile
      GoRoute(
        path: RoutePaths.profile,
        name: RouteNames.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      
      // Settings
      GoRoute(
        path: RoutePaths.settings,
        name: RouteNames.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}

/// Route paths
class RoutePaths {
  RoutePaths._();
  
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String home = '/home';
  static const String swipe = '/swipe';
  static const String matches = '/matches';
  static const String chatList = '/chats';
  static const String chatDetail = '/chats/:matchId';
  static const String profile = '/profile';
  static const String settings = '/settings';
}

/// Route names
class RouteNames {
  RouteNames._();
  
  static const String splash = 'splash';
  static const String onboarding = 'onboarding';
  static const String login = 'login';
  static const String home = 'home';
  static const String swipe = 'swipe';
  static const String matches = 'matches';
  static const String chatList = 'chatList';
  static const String chatDetail = 'chatDetail';
  static const String profile = 'profile';
  static const String settings = 'settings';
}


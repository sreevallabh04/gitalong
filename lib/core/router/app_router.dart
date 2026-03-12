import 'package:go_router/go_router.dart';

import '../../presentation/bloc/auth/auth_bloc.dart';
import '../../presentation/bloc/auth/auth_state.dart';
import '../../presentation/screens/splash_screen.dart';
import '../../presentation/screens/onboarding_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/swipe/swipe_screen.dart';
import '../../presentation/screens/matches/matches_screen.dart';
import '../../presentation/screens/chat/chat_list_screen.dart';
import '../../presentation/screens/chat/chat_detail_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/profile/edit_profile_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import 'go_router_refresh_stream.dart';

/// App router configuration
class AppRouter {
  AppRouter._();

  static GoRouter createRouter(AuthBloc authBloc) {
    return GoRouter(
      initialLocation: RoutePaths.splash,
      debugLogDiagnostics: true,
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
      redirect: (context, state) {
        final authState = authBloc.state;
        final isAuthenticated = authState is AuthAuthenticated;
        final isLoading =
            authState is AuthInitial || authState is AuthLoading;

        final loc = state.matchedLocation;
        final isPublic = loc == RoutePaths.splash ||
            loc == RoutePaths.login ||
            loc == RoutePaths.onboarding;

        // Wait while auth resolves — stay on splash
        if (isLoading) return null;

        // Authenticated user landing on a public route → go home
        if (isAuthenticated && isPublic) return RoutePaths.home;

        // Unauthenticated user trying to access a protected route → go login
        if (!isAuthenticated && !isPublic) return RoutePaths.login;

        return null;
      },
      routes: [
        GoRoute(
          path: RoutePaths.splash,
          name: RouteNames.splash,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: RoutePaths.onboarding,
          name: RouteNames.onboarding,
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: RoutePaths.login,
          name: RouteNames.login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: RoutePaths.home,
          name: RouteNames.home,
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: RoutePaths.swipe,
          name: RouteNames.swipe,
          builder: (context, state) => const SwipeScreen(),
        ),
        GoRoute(
          path: RoutePaths.matches,
          name: RouteNames.matches,
          builder: (context, state) => const MatchesScreen(),
        ),
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
            final extra = state.extra as Map<String, String?>?;
            final otherUserName = extra?['otherUserName'];
            final otherUserAvatar = extra?['otherUserAvatar'];
            return ChatDetailScreen(
              matchId: matchId,
              otherUserName: otherUserName,
              otherUserAvatar: otherUserAvatar,
            );
          },
        ),
        GoRoute(
          path: RoutePaths.profile,
          name: RouteNames.profile,
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: RoutePaths.editProfile,
          name: RouteNames.editProfile,
          builder: (context, state) => const EditProfileScreen(),
        ),
        GoRoute(
          path: RoutePaths.settings,
          name: RouteNames.settings,
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    );
  }
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
  static const String editProfile = '/profile/edit';
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
  static const String editProfile = 'editProfile';
  static const String settings = 'settings';
}

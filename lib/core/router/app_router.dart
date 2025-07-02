import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/auth_provider.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/onboarding/onboarding_screen.dart';
import '../../screens/home/main_navigation_screen.dart';
import '../../core/utils/logger.dart';
import '../../widgets/email_verification_banner.dart';

// ============================================================================
// 🎯 ROUTE PATHS - CENTRALIZED DIVINE NAVIGATION
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
  static const String settings = '/settings';
  static const String editProfile = '/profile/edit';
  static const String userProfile = '/user/:userId';
  static const String chat = '/chat/:chatId';
  static const String projectDetails = '/project/:projectId';
}

// ============================================================================
// 🛡️ AUTH GATE - THE GUARDIAN OF NAVIGATION
// ============================================================================
class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  bool _hasNavigated = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) => _handleAuthenticatedUser(user),
      loading: () => const _SplashLoadingScreen(),
      error: (error, stack) => _handleAuthError(error, stack),
    );
  }

  Widget _handleAuthenticatedUser(User? user) {
    if (user == null) {
      _navigateIfNeeded(() {
        AppLogger.logger
            .navigation('🔐 User not authenticated, redirecting to login');
        context.go(AppRoutes.login);
      });
      return const _SplashLoadingScreen();
    }

    if (!user.emailVerified) {
      return _EmailVerificationBlock(user: user);
    }

    // User is authenticated, check profile status
    final profileProvider = ref.watch(userProfileProvider);

    return profileProvider.when(
      data: (profile) => _handleProfileData(user, profile),
      loading: () => const _SplashLoadingScreen(),
      error: (error, stack) => _handleProfileError(error, stack),
    );
  }

  Widget _handleProfileData(User user, dynamic profile) {
    if (profile == null) {
      _navigateIfNeeded(() {
        AppLogger.logger
            .navigation('📝 Profile missing, redirecting to onboarding');
        context.go(AppRoutes.onboarding);
      });
      return const _SplashLoadingScreen();
    }

    _navigateIfNeeded(() {
      AppLogger.logger.navigation('🏠 Profile exists, redirecting to home');
      context.go(AppRoutes.home);
    });
    return const _SplashLoadingScreen();
  }

  Widget _handleProfileError(dynamic error, StackTrace stack) {
    AppLogger.logger.e('❌ Error loading profile in AuthGate',
        error: error, stackTrace: stack);

    // If it's a profile not found error, go to onboarding
    if (error.toString().toLowerCase().contains('profile') ||
        error.toString().toLowerCase().contains('not found')) {
      _navigateIfNeeded(() {
        AppLogger.logger
            .navigation('📝 Profile error detected, redirecting to onboarding');
        context.go(AppRoutes.onboarding);
      });
    } else {
      // For other errors, go to login to re-authenticate
      _navigateIfNeeded(() {
        AppLogger.logger
            .navigation('🔐 Auth error detected, redirecting to login');
        context.go(AppRoutes.login);
      });
    }

    return const _SplashLoadingScreen();
  }

  Widget _handleAuthError(dynamic error, StackTrace stack) {
    AppLogger.logger
        .e('❌ Auth state error in AuthGate', error: error, stackTrace: stack);

    _navigateIfNeeded(() {
      AppLogger.logger.navigation('🔐 Auth state error, redirecting to login');
      context.go(AppRoutes.login);
    });

    return const _SplashLoadingScreen();
  }

  void _navigateIfNeeded(VoidCallback navigationAction) {
    if (!_hasNavigated) {
      _hasNavigated = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          navigationAction();
        }
      });
    }
  }
}

// ============================================================================
// 🎨 DIVINE SPLASH LOADING SCREEN
// ============================================================================
class _SplashLoadingScreen extends StatelessWidget {
  const _SplashLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117), // GitHub dark
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated GitAlong logo
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1200),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.8 + (0.2 * value),
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF238636), Color(0xFF2EA043)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF238636).withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.code_rounded,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),

            // App name with typewriter effect
            TweenAnimationBuilder<int>(
              tween: IntTween(begin: 0, end: 8),
              duration: const Duration(milliseconds: 1000),
              builder: (context, value, child) {
                return Text(
                  'GitAlong'.substring(0, value),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF0F6FC),
                    letterSpacing: 2,
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            const Text(
              'Connecting Developers Worldwide',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF7D8590),
                letterSpacing: 1,
              ),
            ),

            const SizedBox(height: 48),

            // Loading indicator
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF238636)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 🚀 GOROUTER CONFIGURATION - NAVIGATION PERFECTION
// ============================================================================
final _router = GoRouter(
  initialLocation: AppRoutes.splash,
  debugLogDiagnostics: true,
  refreshListenable:
      GoRouterRefreshStream(FirebaseAuth.instance.authStateChanges()),
  redirect: (context, state) {
    final user = FirebaseAuth.instance.currentUser;
    final isLoggedIn = user != null;
    final currentLocation = state.uri.toString();

    AppLogger.logger.navigation(
      '🔄 Router redirect - User: ${user?.email ?? "null"}, Location: $currentLocation',
    );

    // Define route types
    final isPublicRoute = currentLocation == AppRoutes.login ||
        currentLocation == AppRoutes.splash;
    final isAuthenticatedRoute = currentLocation.startsWith('/home') ||
        currentLocation == AppRoutes.onboarding ||
        currentLocation == AppRoutes.settings ||
        currentLocation == AppRoutes.editProfile;

    // Handle unauthenticated users
    if (!isLoggedIn && !isPublicRoute) {
      AppLogger.logger.navigation(
          '🔐 Unauthenticated user accessing protected route, redirecting to login');
      return AppRoutes.login;
    }

    // Handle authenticated users on login page
    if (isLoggedIn && currentLocation == AppRoutes.login) {
      AppLogger.logger.navigation(
          '✅ Authenticated user on login page, redirecting to splash for evaluation');
      return AppRoutes.splash;
    }

    // Let AuthGate handle the rest for authenticated users
    if (isLoggedIn && currentLocation == AppRoutes.splash) {
      return null; // Let AuthGate decide
    }

    // Prevent navigation loops
    return null;
  },
  errorBuilder: (context, state) => _ErrorScreen(state: state),
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

    // Additional Routes
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

// ============================================================================
// 🎨 DIVINE ERROR SCREEN
// ============================================================================
class _ErrorScreen extends StatelessWidget {
  final GoRouterState state;

  const _ErrorScreen({required this.state});

  @override
  Widget build(BuildContext context) {
    AppLogger.logger.e('❌ Router error: ${state.error}');

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Error icon with glow effect
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFDA3633), Color(0xFFF85149)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFDA3633).withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  color: Colors.white,
                  size: 50,
                ),
              ),

              const SizedBox(height: 32),

              const Text(
                'Navigation Error',
                style: TextStyle(
                  color: Color(0xFFF0F6FC),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              Text(
                'Something went wrong while navigating',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFF7D8590),
                      height: 1.5,
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF21262D),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF30363D)),
                ),
                child: Text(
                  'Route: ${state.uri}',
                  style: const TextStyle(
                    color: Color(0xFF7D8590),
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => context.go(AppRoutes.splash),
                  icon: const Icon(Icons.home_rounded, color: Colors.white),
                  label: const Text(
                    'Go Home',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF238636),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 🌊 GOROUTER REFRESH STREAM - REACTIVE NAVIGATION
// ============================================================================
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) {
        AppLogger.logger.navigation('🔄 Auth state changed, refreshing router');
        notifyListeners();
      },
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

// ============================================================================
// 🎯 ROUTER PROVIDER & NAVIGATION EXTENSIONS
// ============================================================================
final routerProvider = Provider<GoRouter>((ref) => _router);

extension AppNavigation on BuildContext {
  // Auth Navigation
  void goToLogin() {
    AppLogger.logger.navigation('🔄 Navigating to login');
    go(AppRoutes.login);
  }

  void goToOnboarding() {
    AppLogger.logger.navigation('🔄 Navigating to onboarding');
    go(AppRoutes.onboarding);
  }

  void goToHome() {
    AppLogger.logger.navigation('🔄 Navigating to home');
    go(AppRoutes.home);
  }

  // Home Navigation
  void goToSwipe() {
    AppLogger.logger.navigation('🔄 Navigating to swipe');
    go(AppRoutes.swipe);
  }

  void goToMessages() {
    AppLogger.logger.navigation('🔄 Navigating to messages');
    go(AppRoutes.messages);
  }

  void goToSaved() {
    AppLogger.logger.navigation('🔄 Navigating to saved');
    go(AppRoutes.saved);
  }

  void goToProfile() {
    AppLogger.logger.navigation('🔄 Navigating to profile');
    go(AppRoutes.profile);
  }

  // Advanced Navigation
  void navigateWithLog(String route, {Object? extra}) {
    AppLogger.logger.navigation('🔄 Advanced navigation to: $route');
    if (extra != null) {
      go(route, extra: extra);
    } else {
      go(route);
    }
  }

  void navigateAndReplace(String route) {
    AppLogger.logger.navigation('🔄 Navigate and replace to: $route');
    go(route);
  }
}

// ============================================================================
// 📱 PLACEHOLDER SCREENS - TEMPORARY IMPLEMENTATIONS
// ============================================================================
class UserProfileScreen extends StatelessWidget {
  final String userId;
  const UserProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        title: Text('User: $userId'),
        backgroundColor: const Color(0xFF21262D),
      ),
      body: const Center(
        child: Text(
          'User Profile Screen',
          style: TextStyle(color: Color(0xFFF0F6FC)),
        ),
      ),
    );
  }
}

class ChatScreen extends StatelessWidget {
  final String chatId;
  const ChatScreen({super.key, required this.chatId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        title: Text('Chat: $chatId'),
        backgroundColor: const Color(0xFF21262D),
      ),
      body: const Center(
        child: Text(
          'Chat Screen',
          style: TextStyle(color: Color(0xFFF0F6FC)),
        ),
      ),
    );
  }
}

class ProjectDetailsScreen extends StatelessWidget {
  final String projectId;
  const ProjectDetailsScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        title: Text('Project: $projectId'),
        backgroundColor: const Color(0xFF21262D),
      ),
      body: const Center(
        child: Text(
          'Project Details Screen',
          style: TextStyle(color: Color(0xFFF0F6FC)),
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFF21262D),
      ),
      body: const Center(
        child: Text(
          'Settings Screen',
          style: TextStyle(color: Color(0xFFF0F6FC)),
        ),
      ),
    );
  }
}

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: const Color(0xFF21262D),
      ),
      body: const Center(
        child: Text(
          'Edit Profile Screen',
          style: TextStyle(color: Color(0xFFF0F6FC)),
        ),
      ),
    );
  }
}

// Export the router
class AppRouter {
  static GoRouter get router => _router;
}

class _EmailVerificationBlock extends StatefulWidget {
  final User user;
  const _EmailVerificationBlock({required this.user});
  @override
  State<_EmailVerificationBlock> createState() =>
      _EmailVerificationBlockState();
}

class _EmailVerificationBlockState extends State<_EmailVerificationBlock> {
  bool _isLoading = false;
  String? _message;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: Column(
        children: [
          if (_message != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(_message!,
                  style: const TextStyle(color: Color(0xFF2EA043))),
            ),
          EmailVerificationBanner(
            onRefresh: !_isLoading ? () => _onRefresh() : () {},
            onResend: !_isLoading ? () => _onResend() : () {},
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(color: Color(0xFF2EA043)),
            ),
        ],
      ),
    );
  }

  Future<void> _onRefresh() async {
    setState(() => _isLoading = true);
    try {
      await widget.user.reload();
      final refreshed = FirebaseAuth.instance.currentUser;
      if (refreshed != null && refreshed.emailVerified) {
        setState(() => _message = '✅ Email verified! Redirecting...');
        // Give user a moment to see the success message, then trigger navigation
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          // This will trigger the auth state change and navigate appropriately
        }
      } else {
        setState(() =>
            _message = '⏳ Email not yet verified. Please check your inbox.');
      }
    } catch (e) {
      setState(() =>
          _message = '❌ Error checking verification status. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onResend() async {
    setState(() => _isLoading = true);
    try {
      await widget.user.sendEmailVerification();
      setState(() {
        _isLoading = false;
        _message =
            '📧 Verification email sent! Check your inbox and spam folder.';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _message = '❌ Failed to send verification email. Please try again.';
      });
    }
  }
}

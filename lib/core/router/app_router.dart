import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Screens
import '../../screens/auth/login_screen.dart';
import '../../screens/onboarding/onboarding_screen.dart';
import '../../screens/home/main_navigation_screen.dart';
import '../../screens/splash_screen.dart';
import '../../screens/project/project_upload_screen.dart';
import '../../screens/error/route_error_screen.dart';

// Providers
import '../../providers/auth_provider.dart';

// Utils
import '../utils/logger.dart';
import '../monitoring/analytics_service.dart';

// ============================================================================
// 🎯 PRODUCTION-GRADE ROUTE DEFINITIONS WITH ENHANCED DEEP LINKING
// ============================================================================
class AppRoutes {
  // Public routes (no authentication required)
  static const String splash = '/';
  static const String login = '/login';
  static const String error = '/error';

  // Semi-protected routes (authenticated but may need email verification)
  static const String emailVerification = '/email-verification';
  static const String onboarding = '/onboarding';

  // Protected routes (authenticated + verified + profile complete)
  static const String home = '/home';
  static const String discover = '/home/discover';
  static const String messages = '/home/messages';
  static const String saved = '/home/saved';
  static const String profile = '/home/profile';
  static const String projectUpload = '/project/upload';
  static const String settings = '/settings';

  // Maintenance and admin routes
  static const String maintenance = '/maintenance';
  static const String admin = '/admin';

  // Enhanced deep linking routes with query parameter support
  static const String projectDetail = '/project/:projectId';
  static const String userProfile = '/user/:userId';
  static const String chat = '/chat/:chatId';
  static const String emailVerified = '/email-verified';
  static const String resetPassword = '/reset-password';

  // New deep linking routes for enhanced navigation
  static const String projectShare = '/share/project/:projectId';
  static const String userShare = '/share/user/:userId';
  static const String inviteJoin = '/invite/:inviteCode';
  static const String projectReview = '/review/project/:projectId';
  static const String contributorApplication = '/apply/:projectId';

  // Dynamic route patterns
  static String projectDetailWithParams(
    String projectId, {
    String? from,
    String? tab,
    String? highlight,
    Map<String, String>? customParams,
  }) {
    var route = projectDetail.replaceAll(':projectId', projectId);
    final params = <String, String>{};

    if (from != null) params['from'] = from;
    if (tab != null) params['tab'] = tab;
    if (highlight != null) params['highlight'] = highlight;
    if (customParams != null) params.addAll(customParams);

    if (params.isNotEmpty) {
      final query = params.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');
      route = '$route?$query';
    }

    return route;
  }

  static String chatWithParams(
    String chatId, {
    String? projectId,
    String? messageId,
    String? action,
  }) {
    var route = chat.replaceAll(':chatId', chatId);
    final params = <String, String>{};

    if (projectId != null) params['projectId'] = projectId;
    if (messageId != null) params['messageId'] = messageId;
    if (action != null) params['action'] = action;

    if (params.isNotEmpty) {
      final query = params.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');
      route = '$route?$query';
    }

    return route;
  }
}

// ============================================================================
// 🛡️ ENHANCED AUTHENTICATION GUARD ENUMS
// ============================================================================
enum AuthRequirement {
  none, // Public routes
  authenticated, // Must be signed in
  verified, // Must be signed in + email verified
  complete, // Must be signed in + verified + profile complete
  admin, // Must be admin
}

enum LoadingState {
  loading,
  loaded,
  error,
}

enum RouteTransition {
  slide,
  fade,
  scale,
  none,
}

// ============================================================================
// 📊 NAVIGATION ANALYTICS TRACKING
// ============================================================================
class NavigationAnalytics {
  static final Map<String, DateTime> _routeStartTimes = {};
  static String? _currentRoute;
  static int _routeDepth = 0;

  static Future<void> trackRouteEntry(
      String routeName, Map<String, String> params) async {
    _routeStartTimes[routeName] = DateTime.now();
    _routeDepth++;
    _currentRoute = routeName;

    await AnalyticsService.trackScreenView(routeName);
    await AnalyticsService.trackCustomEvent(
      eventName: 'route_entered',
      parameters: {
        'route_name': routeName,
        'route_depth': _routeDepth,
        'has_params': params.isNotEmpty,
        'param_count': params.length,
        ...params.map((k, v) => MapEntry('param_$k', v)),
      },
    );

    AppLogger.logger
        .navigation('📍 Route entered: $routeName (depth: $_routeDepth)');
  }

  static Future<void> trackRouteExit(String routeName) async {
    final startTime = _routeStartTimes[routeName];
    if (startTime != null) {
      final duration = DateTime.now().difference(startTime);
      _routeStartTimes.remove(routeName);

      await AnalyticsService.trackCustomEvent(
        eventName: 'route_exited',
        parameters: {
          'route_name': routeName,
          'duration_seconds': duration.inSeconds,
          'duration_ms': duration.inMilliseconds,
        },
      );

      AppLogger.logger
          .navigation('📍 Route exited: $routeName (${duration.inSeconds}s)');
    }

    _routeDepth = (_routeDepth - 1).clamp(0, 999);
  }

  static Future<void> trackDeepLink(String originalUrl, String resolvedRoute,
      Map<String, String> params) async {
    await AnalyticsService.trackCustomEvent(
      eventName: 'deep_link_accessed',
      parameters: {
        'original_url': originalUrl,
        'resolved_route': resolvedRoute,
        'param_count': params.length,
        'is_external': !originalUrl.startsWith('/'),
        ...params.map((k, v) => MapEntry('param_$k', v)),
      },
    );

    AppLogger.logger
        .navigation('🔗 Deep link accessed: $originalUrl → $resolvedRoute');
  }

  static Future<void> trackNavigationError(String route, String error,
      {String? action}) async {
    await AnalyticsService.trackError(
      errorType: 'navigation_error',
      errorMessage: error,
      errorLocation: route,
    );

    await AnalyticsService.trackCustomEvent(
      eventName: 'navigation_error',
      parameters: {
        'route': route,
        'error': error,
        'action': action ?? 'unknown',
        'current_route': _currentRoute ?? 'unknown',
      },
    );

    AppLogger.logger.e('🚨 Navigation error on $route: $error');
  }
}

// ============================================================================
// 🔄 ENHANCED ERROR HANDLING WITH RETRY MECHANISMS
// ============================================================================
class RouterErrorHandler {
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  static Future<bool> handleNavigationError(
    String route,
    Exception error, {
    VoidCallback? onRetry,
    VoidCallback? onGiveUp,
  }) async {
    await NavigationAnalytics.trackNavigationError(route, error.toString());

    // Try to recover based on error type
    if (error.toString().contains('network') ||
        error.toString().contains('timeout') ||
        error.toString().contains('connection')) {
      return _handleNetworkError(route, onRetry, onGiveUp);
    }

    if (error.toString().contains('auth') ||
        error.toString().contains('permission')) {
      return _handleAuthError(route);
    }

    // Generic error handling
    return _handleGenericError(route, error, onRetry, onGiveUp);
  }

  static Future<bool> _handleNetworkError(
    String route,
    VoidCallback? onRetry,
    VoidCallback? onGiveUp,
  ) async {
    AppLogger.logger
        .w('🌐 Network error on route $route, implementing retry logic');

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      await Future.delayed(retryDelay * attempt);

      try {
        // Attempt recovery
        onRetry?.call();
        AppLogger.logger
            .i('✅ Network error recovery successful on attempt $attempt');
        return true;
      } catch (e) {
        AppLogger.logger.w('❌ Recovery attempt $attempt failed: $e');

        if (attempt == maxRetries) {
          onGiveUp?.call();
          return false;
        }
      }
    }

    return false;
  }

  static Future<bool> _handleAuthError(String route) async {
    AppLogger.logger.w('🔐 Auth error on route $route, redirecting to login');

    await AnalyticsService.trackAuth(
      action: 'auth_error_redirect',
      method: 'automatic',
      success: false,
      errorCode: 'route_auth_error',
    );

    // Will be handled by the redirect logic in the router
    return false;
  }

  static Future<bool> _handleGenericError(
    String route,
    Exception error,
    VoidCallback? onRetry,
    VoidCallback? onGiveUp,
  ) async {
    AppLogger.logger.e('🚨 Generic error on route $route: $error');

    // Simple retry for generic errors
    try {
      await Future.delayed(const Duration(seconds: 1));
      onRetry?.call();
      return true;
    } catch (e) {
      AppLogger.logger.e('❌ Generic error recovery failed: $e');
      onGiveUp?.call();
      return false;
    }
  }
}

// ============================================================================
// 💀 SKELETON SCREEN COMPONENTS FOR LOADING STATES
// ============================================================================
class SkeletonLoader extends StatefulWidget {
  final double height;
  final double width;
  final double borderRadius;
  final EdgeInsets margin;

  const SkeletonLoader({
    super.key,
    this.height = 20,
    this.width = double.infinity,
    this.borderRadius = 8,
    this.margin = EdgeInsets.zero,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            height: widget.height,
            width: widget.width,
            decoration: BoxDecoration(
              color:
                  const Color(0xFF30363D).withValues(alpha: _animation.value),
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
          );
        },
      ),
    );
  }
}

class RouteLoadingScreen extends StatelessWidget {
  final String routeName;
  final String? message;

  const RouteLoadingScreen({
    super.key,
    required this.routeName,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Header skeleton
              const Row(
                children: [
                  SkeletonLoader(height: 40, width: 40, borderRadius: 20),
                  SizedBox(width: 16),
                  Expanded(
                    child: SkeletonLoader(height: 24, width: double.infinity),
                  ),
                  SizedBox(width: 16),
                  SkeletonLoader(height: 40, width: 40, borderRadius: 20),
                ],
              ),

              const SizedBox(height: 32),

              // Content skeletons based on route type
              if (routeName.contains('project')) ..._buildProjectSkeleton(),
              if (routeName.contains('chat')) ..._buildChatSkeleton(),
              if (routeName.contains('profile')) ..._buildProfileSkeleton(),
              if (routeName.contains('discover')) ..._buildDiscoverSkeleton(),

              const Spacer(),

              // Loading indicator
              const CircularProgressIndicator(
                color: Color(0xFF238636),
                strokeWidth: 2,
              ),

              const SizedBox(height: 16),

              Text(
                message ?? 'Loading $routeName...',
                style: const TextStyle(
                  color: Color(0xFF7D8590),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildProjectSkeleton() {
    return [
      // Project header
      const SkeletonLoader(
          height: 32,
          width: double.infinity,
          margin: EdgeInsets.only(bottom: 16)),
      const SkeletonLoader(
          height: 20, width: 200, margin: EdgeInsets.only(bottom: 24)),

      // Project details
      const Row(
        children: [
          SkeletonLoader(height: 80, width: 80, borderRadius: 12),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoader(
                    height: 16,
                    width: double.infinity,
                    margin: EdgeInsets.only(bottom: 8)),
                SkeletonLoader(
                    height: 16, width: 150, margin: EdgeInsets.only(bottom: 8)),
                Row(
                  children: [
                    SkeletonLoader(height: 24, width: 60, borderRadius: 12),
                    SizedBox(width: 8),
                    SkeletonLoader(height: 24, width: 60, borderRadius: 12),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildChatSkeleton() {
    return [
      // Chat header
      const Row(
        children: [
          SkeletonLoader(height: 40, width: 40, borderRadius: 20),
          SizedBox(width: 12),
          Expanded(child: SkeletonLoader(height: 20, width: double.infinity)),
        ],
      ),

      const SizedBox(height: 24),

      // Message bubbles
      ...List.generate(
          5,
          (index) => Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: Row(
                  mainAxisAlignment: index % 2 == 0
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.end,
                  children: [
                    if (index % 2 == 0) ...[
                      const SkeletonLoader(
                          height: 32, width: 32, borderRadius: 16),
                      const SizedBox(width: 8),
                    ],
                    SkeletonLoader(
                      height: 48,
                      width: 200,
                      borderRadius: 16,
                      margin: EdgeInsets.only(
                        left: index % 2 == 1 ? 80 : 0,
                        right: index % 2 == 0 ? 80 : 0,
                      ),
                    ),
                    if (index % 2 == 1) ...[
                      const SizedBox(width: 8),
                      const SkeletonLoader(
                          height: 32, width: 32, borderRadius: 16),
                    ],
                  ],
                ),
              )),
    ];
  }

  List<Widget> _buildProfileSkeleton() {
    return [
      // Profile header
      const Center(
        child: Column(
          children: [
            SkeletonLoader(height: 100, width: 100, borderRadius: 50),
            SizedBox(height: 16),
            SkeletonLoader(height: 24, width: 150),
            SizedBox(height: 8),
            SkeletonLoader(height: 16, width: 100),
          ],
        ),
      ),

      const SizedBox(height: 32),

      // Profile details
      const SkeletonLoader(
          height: 20,
          width: double.infinity,
          margin: EdgeInsets.only(bottom: 16)),
      const SkeletonLoader(
          height: 16,
          width: double.infinity,
          margin: EdgeInsets.only(bottom: 8)),
      const SkeletonLoader(
          height: 16, width: 200, margin: EdgeInsets.only(bottom: 24)),

      // Skills
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: List.generate(
            6,
            (index) => SkeletonLoader(
                height: 32, width: 60 + (index * 10.0), borderRadius: 16)),
      ),
    ];
  }

  List<Widget> _buildDiscoverSkeleton() {
    return [
      // Search bar
      const SkeletonLoader(
          height: 48,
          width: double.infinity,
          borderRadius: 24,
          margin: EdgeInsets.only(bottom: 24)),

      // Filter chips
      const Row(
        children: [
          SkeletonLoader(height: 32, width: 80, borderRadius: 16),
          SizedBox(width: 8),
          SkeletonLoader(height: 32, width: 60, borderRadius: 16),
          SizedBox(width: 8),
          SkeletonLoader(height: 32, width: 70, borderRadius: 16),
        ],
      ),

      const SizedBox(height: 24),

      // Card items
      ...List.generate(
          3,
          (index) => Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLoader(
                        height: 150, width: double.infinity, borderRadius: 12),
                    SizedBox(height: 12),
                    SkeletonLoader(height: 20, width: double.infinity),
                    SizedBox(height: 8),
                    SkeletonLoader(height: 16, width: 200),
                  ],
                ),
              )),
    ];
  }
}

// ============================================================================
// 🚀 ENHANCED PRODUCTION ROUTER WITH ALL FEATURES
// ============================================================================
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,

    // Global redirect logic with authentication guards
    redirect: (context, state) {
      final currentPath = state.uri.path;
      final authRequirement = _getAuthRequirement(currentPath);

      // Skip redirect for public routes
      if (authRequirement == AuthRequirement.none) {
        AppLogger.logger.navigation('🌍 Public route accessed: $currentPath');
        return null;
      }

      // Get authentication state using ProviderScope
      final container = ProviderScope.containerOf(context);
      final authStateValue = container.read(authStateProvider);

      return authStateValue.when(
        loading: () {
          AppLogger.logger.navigation(
              '⏳ Auth loading, staying on current route: $currentPath');
          return null; // Stay on current route while loading
        },
        error: (error, stackTrace) {
          AppLogger.logger.e('❌ Auth error during navigation', error: error);
          return '${AppRoutes.error}?message=${Uri.encodeComponent(error.toString())}';
        },
        data: (user) => _handleAuthenticatedRedirect(
            user, currentPath, authRequirement, state),
      );
    },

    // Enhanced error handling with analytics
    errorBuilder: (context, state) {
      // Track error for analytics
      AnalyticsService.trackError(
        errorType: 'route_error',
        errorMessage: state.error?.toString() ?? 'Unknown route error',
        errorLocation: state.uri.toString(),
      );

      return RouteErrorScreen(
        error: state.error,
        uri: state.uri,
        onRetry: () => context.go(AppRoutes.splash),
      );
    },

    routes: [
      // ========================================================================
      // 🌟 PUBLIC ROUTES (No Authentication Required)
      // ========================================================================

      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) {
          return const LoginScreen();
        },
      ),

      GoRoute(
        path: AppRoutes.error,
        name: 'error',
        builder: (context, state) {
          final errorMessage =
              state.uri.queryParameters['message'] ?? 'Unknown error';
          return RouteErrorScreen(
            error: Exception(errorMessage),
            uri: state.uri,
            onRetry: () => context.go(AppRoutes.splash),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.emailVerified,
        name: 'email_verified',
        builder: (context, state) => const EmailVerificationSuccessScreen(),
      ),

      GoRoute(
        path: AppRoutes.resetPassword,
        name: 'reset_password',
        builder: (context, state) {
          final token = state.uri.queryParameters['oobCode'];
          return ResetPasswordScreen(resetToken: token);
        },
      ),

      // ========================================================================
      // 🔐 SEMI-PROTECTED ROUTES (Authentication Required)
      // ========================================================================

      GoRoute(
        path: AppRoutes.emailVerification,
        name: 'email_verification',
        builder: (context, state) => const EmailVerificationScreen(),
      ),

      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // ========================================================================
      // 🏠 PROTECTED ROUTES (Full Authentication + Verification Required)
      // ========================================================================

      ShellRoute(
        builder: (context, state, child) => MainNavigationShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            name: 'home',
            builder: (context, state) => const MainNavigationScreen(),
            routes: [
              GoRoute(
                path: 'discover',
                name: 'discover',
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
        ],
      ),

      GoRoute(
        path: AppRoutes.projectUpload,
        name: 'project_upload',
        builder: (context, state) => const ProjectUploadScreen(),
      ),

      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),

      // ========================================================================
      // 🔗 DEEP LINKING ROUTES
      // ========================================================================

      // Enhanced deep linking routes with analytics and loading states
      GoRoute(
        path: AppRoutes.projectDetail,
        name: 'project_detail',
        builder: (context, state) {
          final projectId = state.pathParameters['projectId']!;
          final fromRoute = state.uri.queryParameters['from'];
          final tab = state.uri.queryParameters['tab'];
          final highlight = state.uri.queryParameters['highlight'];

          // Track deep link analytics
          NavigationAnalytics.trackDeepLink(
            state.uri.toString(),
            'project_detail',
            {
              'project_id': projectId,
              'from': fromRoute ?? 'direct',
              'tab': tab ?? 'default',
              'has_highlight': highlight != null ? 'true' : 'false',
            },
          );

          return ProjectDetailScreen(
            projectId: projectId,
            previousRoute: fromRoute,
            initialTab: tab,
            highlightElement: highlight,
          );
        },
      ),

      GoRoute(
        path: AppRoutes.userProfile,
        name: 'user_profile',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          final queryParams = state.uri.queryParameters;

          // Track deep link analytics
          NavigationAnalytics.trackDeepLink(
            state.uri.toString(),
            'user_profile',
            {'user_id': userId, ...queryParams},
          );

          return UserProfileScreen(
            userId: userId,
            queryParameters: queryParams,
          );
        },
      ),

      GoRoute(
        path: AppRoutes.chat,
        name: 'chat',
        builder: (context, state) {
          final chatId = state.pathParameters['chatId']!;
          final projectId = state.uri.queryParameters['projectId'];
          final messageId = state.uri.queryParameters['messageId'];
          final action = state.uri.queryParameters['action'];

          // Track deep link analytics
          NavigationAnalytics.trackDeepLink(
            state.uri.toString(),
            'chat',
            {
              'chat_id': chatId,
              'project_id': projectId ?? 'none',
              'message_id': messageId ?? 'none',
              'action': action ?? 'open',
            },
          );

          return ChatScreen(
            chatId: chatId,
            projectId: projectId,
            messageId: messageId,
            action: action,
          );
        },
      ),

      // Enhanced share and invite routes
      GoRoute(
        path: AppRoutes.projectShare,
        name: 'project_share',
        builder: (context, state) {
          final projectId = state.pathParameters['projectId']!;
          final source = state.uri.queryParameters['source'];

          NavigationAnalytics.trackDeepLink(
            state.uri.toString(),
            'project_share',
            {'project_id': projectId, 'source': source ?? 'direct'},
          );

          return ProjectShareScreen(
            projectId: projectId,
            source: source,
          );
        },
      ),

      GoRoute(
        path: AppRoutes.userShare,
        name: 'user_share',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          final source = state.uri.queryParameters['source'];

          NavigationAnalytics.trackDeepLink(
            state.uri.toString(),
            'user_share',
            {'user_id': userId, 'source': source ?? 'direct'},
          );

          return UserShareScreen(
            userId: userId,
            source: source,
          );
        },
      ),

      GoRoute(
        path: AppRoutes.inviteJoin,
        name: 'invite_join',
        builder: (context, state) {
          final inviteCode = state.pathParameters['inviteCode']!;
          final referrer = state.uri.queryParameters['ref'];

          NavigationAnalytics.trackDeepLink(
            state.uri.toString(),
            'invite_join',
            {'invite_code': inviteCode, 'referrer': referrer ?? 'none'},
          );

          return InviteJoinScreen(
            inviteCode: inviteCode,
            referrer: referrer,
          );
        },
      ),

      GoRoute(
        path: AppRoutes.projectReview,
        name: 'project_review',
        builder: (context, state) {
          final projectId = state.pathParameters['projectId']!;
          final queryParams = state.uri.queryParameters;

          NavigationAnalytics.trackDeepLink(
            state.uri.toString(),
            'project_review',
            {'project_id': projectId, ...queryParams},
          );

          return ProjectReviewScreen(
            projectId: projectId,
            queryParameters: queryParams,
          );
        },
      ),

      GoRoute(
        path: AppRoutes.contributorApplication,
        name: 'contributor_application',
        builder: (context, state) {
          final projectId = state.pathParameters['projectId']!;
          final queryParams = state.uri.queryParameters;

          NavigationAnalytics.trackDeepLink(
            state.uri.toString(),
            'contributor_application',
            {'project_id': projectId, ...queryParams},
          );

          return ContributorApplicationScreen(
            projectId: projectId,
            queryParameters: queryParams,
          );
        },
      ),

      // ========================================================================
      // 🔧 MAINTENANCE AND ADMIN ROUTES
      // ========================================================================

      GoRoute(
        path: AppRoutes.maintenance,
        name: 'maintenance',
        builder: (context, state) => const MaintenanceScreen(),
      ),

      GoRoute(
        path: AppRoutes.admin,
        name: 'admin',
        builder: (context, state) => const AdminDashboard(),
      ),
    ],
  );
});

// ============================================================================
// 🛡️ AUTHENTICATION HELPER FUNCTIONS
// ============================================================================

String? _handleAuthenticatedRedirect(
  User? user,
  String currentPath,
  AuthRequirement requirement,
  GoRouterState state,
) {
  switch (requirement) {
    case AuthRequirement.none:
      return null;

    case AuthRequirement.authenticated:
      if (user == null) {
        AppLogger.logger.navigation(
            '🔐 Unauthenticated access to protected route: $currentPath');
        return '${AppRoutes.login}?redirect=${Uri.encodeComponent(currentPath)}';
      }
      return null;

    case AuthRequirement.verified:
      if (user == null) {
        AppLogger.logger.navigation(
            '🔐 Unauthenticated access to verified route: $currentPath');
        return '${AppRoutes.login}?redirect=${Uri.encodeComponent(currentPath)}';
      }
      if (!user.emailVerified) {
        AppLogger.logger.navigation(
            '📧 Unverified email access to verified route: $currentPath');
        return AppRoutes.emailVerification;
      }
      return null;

    case AuthRequirement.complete:
      if (user == null) {
        AppLogger.logger.navigation(
            '🔐 Unauthenticated access to complete route: $currentPath');
        return '${AppRoutes.login}?redirect=${Uri.encodeComponent(currentPath)}';
      }
      if (!user.emailVerified) {
        AppLogger.logger.navigation(
            '📧 Unverified email access to complete route: $currentPath');
        return AppRoutes.emailVerification;
      }
      // Check profile completion status
      // TODO: Add profile completion check here
      return null;

    case AuthRequirement.admin:
      if (user == null) {
        AppLogger.logger.navigation(
            '🔐 Unauthenticated access to admin route: $currentPath');
        return '${AppRoutes.login}?redirect=${Uri.encodeComponent(currentPath)}';
      }
      // TODO: Add admin privilege check here
      return null;
  }
}

AuthRequirement _getAuthRequirement(String path) {
  // Public routes
  if (path == AppRoutes.splash ||
      path == AppRoutes.login ||
      path == AppRoutes.error ||
      path == AppRoutes.emailVerified ||
      path == AppRoutes.resetPassword ||
      path == AppRoutes.maintenance) {
    return AuthRequirement.none;
  }

  // Semi-protected routes
  if (path == AppRoutes.emailVerification) {
    return AuthRequirement.authenticated;
  }

  if (path == AppRoutes.onboarding) {
    return AuthRequirement.verified;
  }

  // Admin routes
  if (path.startsWith(AppRoutes.admin)) {
    return AuthRequirement.admin;
  }

  // All other routes require complete authentication
  return AuthRequirement.complete;
}

// ============================================================================
// 🧭 ENHANCED NAVIGATION EXTENSIONS WITH ANALYTICS AND ERROR HANDLING
// ============================================================================
extension AppNavigation on BuildContext {
  // Public routes with analytics tracking
  Future<void> goToSplash() async {
    await _trackAndNavigate('splash', AppRoutes.splash);
  }

  Future<void> goToLogin({String? redirectAfter}) async {
    final uri = redirectAfter != null
        ? '${AppRoutes.login}?redirect=${Uri.encodeComponent(redirectAfter)}'
        : AppRoutes.login;
    await _trackAndNavigate(
        'login', uri, {'has_redirect': redirectAfter != null});
  }

  // Protected routes with analytics tracking
  Future<void> goToHome() async {
    await _trackAndNavigate('home', AppRoutes.home);
  }

  Future<void> goToDiscover() async {
    await _trackAndNavigate('discover', AppRoutes.discover);
  }

  Future<void> goToMessages() async {
    await _trackAndNavigate('messages', AppRoutes.messages);
  }

  Future<void> goToSaved() async {
    await _trackAndNavigate('saved', AppRoutes.saved);
  }

  Future<void> goToProfile() async {
    await _trackAndNavigate('profile', AppRoutes.profile);
  }

  Future<void> goToOnboarding() async {
    await _trackAndNavigate('onboarding', AppRoutes.onboarding);
  }

  Future<void> goToProjectUpload() async {
    await _trackAndNavigate('project_upload', AppRoutes.projectUpload);
  }

  Future<void> goToSettings() async {
    await _trackAndNavigate('settings', AppRoutes.settings);
  }

  // Enhanced deep linking routes with comprehensive parameter support
  Future<void> goToProject(
    String projectId, {
    String? from,
    String? tab,
    String? highlight,
    Map<String, String>? customParams,
  }) async {
    final uri = AppRoutes.projectDetailWithParams(
      projectId,
      from: from,
      tab: tab,
      highlight: highlight,
      customParams: customParams,
    );

    await _trackAndNavigate('project_detail', uri, {
      'project_id': projectId,
      'from_route': from ?? 'direct',
      'has_tab': tab != null,
      'has_highlight': highlight != null,
      'custom_param_count': customParams?.length ?? 0,
    });
  }

  Future<void> goToUser(String userId, {Map<String, String>? params}) async {
    var uri = AppRoutes.userProfile.replaceAll(':userId', userId);

    if (params != null && params.isNotEmpty) {
      final query = params.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');
      uri = '$uri?$query';
    }

    await _trackAndNavigate('user_profile', uri, {
      'user_id': userId,
      'param_count': params?.length ?? 0,
    });
  }

  Future<void> goToChat(
    String chatId, {
    String? projectId,
    String? messageId,
    String? action,
  }) async {
    final uri = AppRoutes.chatWithParams(
      chatId,
      projectId: projectId,
      messageId: messageId,
      action: action,
    );

    await _trackAndNavigate('chat', uri, {
      'chat_id': chatId,
      'has_project': projectId != null,
      'has_message_id': messageId != null,
      'action': action ?? 'open',
    });
  }

  // Enhanced share routes
  Future<void> goToProjectShare(String projectId, {String? source}) async {
    final route = AppRoutes.projectShare.replaceAll(':projectId', projectId);
    final uri =
        source != null ? '$route?source=${Uri.encodeComponent(source)}' : route;

    await _trackAndNavigate('project_share', uri, {
      'project_id': projectId,
      'source': source ?? 'unknown',
    });
  }

  Future<void> goToUserShare(String userId, {String? source}) async {
    final route = AppRoutes.userShare.replaceAll(':userId', userId);
    final uri =
        source != null ? '$route?source=${Uri.encodeComponent(source)}' : route;

    await _trackAndNavigate('user_share', uri, {
      'user_id': userId,
      'source': source ?? 'unknown',
    });
  }

  Future<void> goToInvite(String inviteCode, {String? referrer}) async {
    final route = AppRoutes.inviteJoin.replaceAll(':inviteCode', inviteCode);
    final uri = referrer != null
        ? '$route?ref=${Uri.encodeComponent(referrer)}'
        : route;

    await _trackAndNavigate('invite_join', uri, {
      'invite_code': inviteCode,
      'has_referrer': referrer != null,
    });
  }

  // Error handling with retry mechanism
  Future<void> goToError(String message,
      {String? action, String? originalRoute}) async {
    var uri = '${AppRoutes.error}?message=${Uri.encodeComponent(message)}';
    if (action != null) uri += '&action=${Uri.encodeComponent(action)}';
    if (originalRoute != null) {
      uri += '&from=${Uri.encodeComponent(originalRoute)}';
    }

    await _trackAndNavigate('error', uri, {
      'error_message': message,
      'action': action ?? 'unknown',
      'original_route': originalRoute ?? 'unknown',
    });
  }

  // Safe navigation with error handling
  Future<bool> safeNavigateTo(String route,
      {Map<String, dynamic>? params}) async {
    try {
      await _trackAndNavigate('safe_navigation', route, params ?? {});
      return true;
    } catch (error) {
      await RouterErrorHandler.handleNavigationError(
        route,
        Exception(error.toString()),
        onRetry: () => go(route),
        onGiveUp: () =>
            goToError('Navigation failed: $error', originalRoute: route),
      );
      return false;
    }
  }

  // Advanced utility methods
  bool get isOnProtectedRoute {
    final location = GoRouterState.of(this).uri.path;
    return _getAuthRequirement(location) != AuthRequirement.none;
  }

  String get currentRouteName {
    final state = GoRouterState.of(this);
    return state.name ?? state.uri.path;
  }

  Map<String, String> get routeParameters {
    return GoRouterState.of(this).pathParameters;
  }

  Map<String, String> get queryParameters {
    return GoRouterState.of(this).uri.queryParameters;
  }

  AuthRequirement get currentAuthRequirement {
    final location = GoRouterState.of(this).uri.path;
    return _getAuthRequirement(location);
  }

  bool get canNavigateBack {
    return canPop();
  }

  Future<void> safeGoBack() async {
    if (canNavigateBack) {
      await AnalyticsService.trackCustomEvent(
        eventName: 'navigation_back',
        parameters: {'from_route': currentRouteName},
      );
      pop();
    } else {
      await goToHome();
    }
  }

  // Route state preservation
  Map<String, dynamic> get routeState {
    return {
      'route': currentRouteName,
      'parameters': routeParameters,
      'query_parameters': queryParameters,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  Future<void> restoreRouteState(Map<String, dynamic> state) async {
    final route = state['route'] as String?;
    if (route != null) {
      await safeNavigateTo(route);
    }
  }

  // Private helper method for tracking navigation
  Future<void> _trackAndNavigate(
    String routeName,
    String destination, [
    Map<String, dynamic>? additionalParams,
  ]) async {
    try {
      // Track route exit if on a tracked route
      final currentRoute = currentRouteName;
      if (currentRoute.isNotEmpty && currentRoute != destination) {
        await NavigationAnalytics.trackRouteExit(currentRoute);
      }

      // Navigate
      go(destination);

      // Track route entry
      final params = <String, String>{};
      params.addAll(GoRouterState.of(this).pathParameters);
      params.addAll(GoRouterState.of(this).uri.queryParameters);

      final trackingParams = additionalParams ?? {};
      trackingParams.addAll(params);

      await NavigationAnalytics.trackRouteEntry(routeName, params);

      AppLogger.logger.navigation('🧭 Navigated to $routeName: $destination');
    } catch (error) {
      await NavigationAnalytics.trackNavigationError(
        destination,
        error.toString(),
        action: 'navigate',
      );

      AppLogger.logger.e('❌ Navigation failed to $destination', error: error);
      rethrow;
    }
  }
}

// ============================================================================
// 🔄 ROUTER REFRESH STREAM FOR REACTIVE UPDATES
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

// ============================================================================
// 🚧 PLACEHOLDER SCREENS (TO BE IMPLEMENTED)
// ============================================================================
class EmailVerificationSuccessScreen extends StatelessWidget {
  const EmailVerificationSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 16),
            const Text('Email Verified Successfully!'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.goToHome(),
              child: const Text('Continue to App'),
            ),
          ],
        ),
      ),
    );
  }
}

class EmailVerificationScreen extends StatelessWidget {
  const EmailVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Email Verification Screen')),
    );
  }
}

class ResetPasswordScreen extends StatelessWidget {
  final String? resetToken;
  const ResetPasswordScreen({super.key, this.resetToken});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Reset Password Screen')),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Settings Screen')),
    );
  }
}

class ProjectDetailScreen extends StatelessWidget {
  final String projectId;
  final String? previousRoute;
  final String? initialTab;
  final String? highlightElement;

  const ProjectDetailScreen({
    super.key,
    required this.projectId,
    this.previousRoute,
    this.initialTab,
    this.highlightElement,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Project Detail: $projectId'),
            if (previousRoute != null) Text('From: $previousRoute'),
            if (initialTab != null) Text('Tab: $initialTab'),
            if (highlightElement != null) Text('Highlight: $highlightElement'),
          ],
        ),
      ),
    );
  }
}

class UserProfileScreen extends StatelessWidget {
  final String userId;
  final Map<String, String>? queryParameters;

  const UserProfileScreen({
    super.key,
    required this.userId,
    this.queryParameters,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('User Profile: $userId'),
            if (queryParameters != null && queryParameters!.isNotEmpty)
              Text('Params: ${queryParameters!.keys.join(', ')}'),
          ],
        ),
      ),
    );
  }
}

class ChatScreen extends StatelessWidget {
  final String chatId;
  final String? projectId;
  final String? messageId;
  final String? action;

  const ChatScreen({
    super.key,
    required this.chatId,
    this.projectId,
    this.messageId,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Chat: $chatId'),
            if (projectId != null) Text('Project: $projectId'),
            if (messageId != null) Text('Message: $messageId'),
            if (action != null) Text('Action: $action'),
          ],
        ),
      ),
    );
  }
}

// New screen placeholders for enhanced deep linking
class ProjectShareScreen extends StatelessWidget {
  final String projectId;
  final String? source;

  const ProjectShareScreen({
    super.key,
    required this.projectId,
    this.source,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Share Project: $projectId'),
            if (source != null) Text('Source: $source'),
          ],
        ),
      ),
    );
  }
}

class UserShareScreen extends StatelessWidget {
  final String userId;
  final String? source;

  const UserShareScreen({
    super.key,
    required this.userId,
    this.source,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Share User: $userId'),
            if (source != null) Text('Source: $source'),
          ],
        ),
      ),
    );
  }
}

class InviteJoinScreen extends StatelessWidget {
  final String inviteCode;
  final String? referrer;

  const InviteJoinScreen({
    super.key,
    required this.inviteCode,
    this.referrer,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Join Invite: $inviteCode'),
            if (referrer != null) Text('Referrer: $referrer'),
          ],
        ),
      ),
    );
  }
}

class ProjectReviewScreen extends StatelessWidget {
  final String projectId;
  final Map<String, String>? queryParameters;

  const ProjectReviewScreen({
    super.key,
    required this.projectId,
    this.queryParameters,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Review Project: $projectId'),
            if (queryParameters != null && queryParameters!.isNotEmpty)
              Text('Params: ${queryParameters!.keys.join(', ')}'),
          ],
        ),
      ),
    );
  }
}

class ContributorApplicationScreen extends StatelessWidget {
  final String projectId;
  final Map<String, String>? queryParameters;

  const ContributorApplicationScreen({
    super.key,
    required this.projectId,
    this.queryParameters,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Apply to Project: $projectId'),
            if (queryParameters != null && queryParameters!.isNotEmpty)
              Text('Params: ${queryParameters!.keys.join(', ')}'),
          ],
        ),
      ),
    );
  }
}

class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Under Maintenance')),
    );
  }
}

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Admin Dashboard')),
    );
  }
}

class MainNavigationShell extends StatelessWidget {
  final Widget child;
  const MainNavigationShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

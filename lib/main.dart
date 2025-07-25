import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/utils/error_handler.dart';
import 'core/utils/logger.dart';
import 'core/utils/error_boundary.dart';
import 'core/utils/production_config.dart';
import 'core/analytics/analytics_service.dart';
import 'config/firebase_config.dart';
import 'services/notification_service.dart';
import 'providers/app_lifecycle_provider.dart';
import 'providers/web_backend_provider.dart';
import 'core/router/app_router.dart';
import 'core/config/app_theme.dart';
import 'core/theme/github_theme.dart';

final githubDarkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF0D1117),
  primaryColor: const Color(0xFF2EA043),
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF2EA043),
    secondary: Color(0xFF238636),
    surface: Color(0xFF161B22),
    onPrimary: Color(0xFFC9D1D9),
    onSurface: Color(0xFFC9D1D9),
    error: Color(0xFFDA3633),
  ),
  textTheme: GoogleFonts.jetBrainsMonoTextTheme(
    ThemeData.dark().textTheme.apply(
          bodyColor: const Color(0xFFC9D1D9),
          displayColor: const Color(0xFFC9D1D9),
        ),
  ),
  cardTheme: CardTheme(
    color: const Color(0xFF161B22),
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    shadowColor: Colors.black.withValues(alpha: 0.2),
    margin: const EdgeInsets.all(12),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF161B22),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFF2EA043), width: 2),
    ),
    labelStyle: const TextStyle(color: Color(0xFFC9D1D9)),
    hintStyle: const TextStyle(color: Color(0xFF7D8590)),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF2EA043),
      foregroundColor: Colors.white,
      textStyle: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 0,
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: const Color(0xFF2EA043),
      textStyle: GoogleFonts.jetBrainsMono(),
      side: const BorderSide(color: Color(0xFF2EA043)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  ),
  snackBarTheme: const SnackBarThemeData(
    backgroundColor: Color(0xFF161B22),
    contentTextStyle: TextStyle(color: Color(0xFFC9D1D9)),
    actionTextColor: Color(0xFF2EA043),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF161B22),
    elevation: 0,
    iconTheme: IconThemeData(color: Color(0xFFC9D1D9)),
    titleTextStyle: TextStyle(
      color: Color(0xFFC9D1D9),
      fontWeight: FontWeight.bold,
      fontSize: 20,
      fontFamily: 'JetBrains Mono',
    ),
  ),
);

void main() async {
  try {
    // Ensure Flutter binding is initialized
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize logging first - critical for production debugging
    AppLogger.initialize();
    AppLogger.logger.i('🚀 Starting GitAlong app initialization...');

    // Initialize global error handling
    GlobalErrorHandler.initialize();
    AppLogger.logger.i('🛡️ Global error handling initialized');

    // Initialize analytics
    await AnalyticsService.initialize();
    AppLogger.logger.i('📊 Analytics service initialized');

    // Initialize production configuration
    AppLogger.logger.i('🔧 Initializing production configuration...');
    await ProductionConfig.initialize();
    ProductionErrorHandler.initialize();
    AppLogger.logger.i('✅ Production configuration initialized');

    // Initialize Firebase using the centralized config FIRST
    AppLogger.logger.i('🔥 Initializing Firebase...');
    await FirebaseConfig.initialize();
    AppLogger.logger.success('✅ Firebase initialized successfully');

    // Initialize Firebase App Check for production security
    try {
      AppLogger.logger.i('🔒 Initializing Firebase App Check...');
      await FirebaseConfig.initializeAppCheck();
      AppLogger.logger.success('✅ Firebase App Check initialized successfully');
    } catch (e) {
      AppLogger.logger.w('⚠️ Firebase App Check initialization failed: $e');
    }

    // Initialize web backend service
    final container = ProviderContainer();
    final webBackend = container.read(webBackendProvider);
    await webBackend.initialize();
    AppLogger.logger.i('🔥 Web backend service initialized');

    // Load environment configuration (optional)
    try {
      await dotenv.load(fileName: ".env");
      AppLogger.logger.d('✅ Environment configuration loaded from .env file');

      // Verify GitHub OAuth credentials are loaded
      final githubClientId = dotenv.env['GITHUB_CLIENT_ID'];
      final githubClientSecret = dotenv.env['GITHUB_CLIENT_SECRET'];
      final githubRedirectUri = dotenv.env['GITHUB_REDIRECT_URI'];

      if (githubClientId != null &&
          githubClientSecret != null &&
          githubRedirectUri != null) {
        AppLogger.logger.d('✅ GitHub OAuth credentials loaded successfully');
      } else {
        AppLogger.logger
            .w('⚠️ GitHub OAuth credentials missing from .env file');
      }
    } catch (e) {
      // Initialize dotenv with empty state first
      dotenv.testLoad(fileInput: '');

      // Set default environment variables for development
      dotenv.env['APP_NAME'] = 'GitAlong';
      dotenv.env['ENVIRONMENT'] = 'development';
      dotenv.env['ENABLE_ANALYTICS'] = 'true';
      dotenv.env['ENABLE_DEBUG_LOGGING'] = 'true';
      dotenv.env['API_TIMEOUT_SECONDS'] = '30';

      AppLogger.logger
          .d('✅ Using default environment configuration (no .env file found)');
      AppLogger.logger.w(
          '⚠️ GitHub OAuth credentials not configured - GitHub features will be disabled');
    }

    // Configure system UI overlay style for GitHub theme
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: AppColors.background,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.surface,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarDividerColor: AppColors.border,
      ),
    );

    // Lock orientation to portrait (optional - remove if you want landscape support)
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Initialize notification service
    AppLogger.logger.i('🔔 Initializing notification service...');
    await NotificationService().initialize();
    AppLogger.logger.success('✅ Notification service initialized successfully');

    // Set up error handling
    _setupErrorHandling();

    // Run the app with GoRouter
    AppLogger.logger.i('🎯 Launching GitAlong app with GoRouter...');
    runApp(const ProviderScope(child: GitAlongApp()));
  } catch (error, stackTrace) {
    AppLogger.logger.e(
      '💥 Critical error during app initialization',
      error: error,
      stackTrace: stackTrace,
    );

    // Show a simple error message and still try to start the app
    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.appThemeData,
        home: Scaffold(
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
                const SizedBox(height: 24),
                const Text(
                  'GitAlong',
                  style: TextStyle(
                    color: Color(0xFFF0F6FC),
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Failed to initialize the app.\nPlease restart the application.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF7D8590), fontSize: 16),
                ),
                const SizedBox(height: 32),
                Text(
                  'Error: ${error.toString()}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF7D8590),
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void _setupErrorHandling() {
  // Catch Flutter framework errors
  FlutterError.onError = (details) {
    AppLogger.logger.e(
      '🚨 Flutter Error caught by global handler',
      error: details.exception,
      stackTrace: details.stack,
    );
    ErrorHandler.handleFlutterError(details);
  };

  // Catch Dart errors outside Flutter framework
  PlatformDispatcher.instance.onError = (error, stack) {
    AppLogger.logger.e(
      '🚨 Platform Error caught by global handler',
      error: error,
      stackTrace: stack,
    );
    return ErrorHandler.handlePlatformError(error, stack);
  };
}

class GitAlongApp extends ConsumerWidget {
  const GitAlongApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the app lifecycle state for better resource management
    ref.watch(appLifecycleProvider);

    // Get the router from provider
    final router = ref.watch(routerProvider);

    return ErrorBoundary(
      child: MaterialApp.router(
        title: 'GitAlong',
        debugShowCheckedModeBanner: false,

        // Use the GitHub-inspired theme
        theme: GitHubTheme.darkTheme,
        themeMode: ThemeMode.dark,

        // GoRouter configuration - this is the key!
        routerConfig: router,

        // Builder for additional global configuration
        builder: (context, child) {
          // Ensure text scaling doesn't break the UI
          final mediaQuery = MediaQuery.of(context);
          return MediaQuery(
            data: mediaQuery.copyWith(
              textScaler: TextScaler.linear(
                mediaQuery.textScaler.scale(1.0).clamp(0.8, 1.2),
              ),
            ),
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}

/// Provider observer for debugging and monitoring
class AppProviderObserver extends ProviderObserver {
  @override
  void didAddProvider(
    ProviderBase<Object?> provider,
    Object? value,
    ProviderContainer container,
  ) {
    AppLogger.logger.d(
      '🔧 Provider added: ${provider.name ?? provider.runtimeType}',
    );
  }

  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    AppLogger.logger.d(
      '🔄 Provider updated: ${provider.name ?? provider.runtimeType}',
    );
  }

  @override
  void didDisposeProvider(
    ProviderBase<Object?> provider,
    ProviderContainer container,
  ) {
    AppLogger.logger.d(
      '🗑️ Provider disposed: ${provider.name ?? provider.runtimeType}',
    );
  }

  @override
  void providerDidFail(
    ProviderBase<Object?> provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    AppLogger.logger.e(
      '❌ Provider failed: ${provider.name ?? provider.runtimeType}',
      error: error,
      stackTrace: stackTrace,
    );
  }
}

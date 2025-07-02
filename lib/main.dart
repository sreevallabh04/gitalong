import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'config/firebase_config.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/error_handler.dart';
import 'core/utils/logger.dart';
import 'providers/app_lifecycle_provider.dart';
import 'core/router/app_router.dart';

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
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    shadowColor: Colors.black.withOpacity(0.2),
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

    // Configure system UI overlay style for GitHub theme
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: GitAlongTheme.carbonBlack,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: GitAlongTheme.surfaceGray,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarDividerColor: GitAlongTheme.borderGray,
      ),
    );

    // Lock orientation to portrait (optional - remove if you want landscape support)
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Initialize Firebase
    AppLogger.logger.i('🔥 Initializing Firebase...');
    await FirebaseConfig.initialize();
    AppLogger.logger.success('✅ Firebase initialized successfully');

    // Set up error handling
    _setupErrorHandling();

    // Run the app with GoRouter
    AppLogger.logger.i('🎯 Launching GitAlong app with GoRouter...');
    runApp(
      const ProviderScope(
        child: GitAlongApp(),
      ),
    );
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
        theme: githubDarkTheme,
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
                  style: TextStyle(
                    color: Color(0xFF7D8590),
                    fontSize: 16,
                  ),
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

    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone 13 mini size as baseline
      minTextAdapt: true,
      splitScreenMode: true,
      useInheritedMediaQuery: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'GitAlong',
          debugShowCheckedModeBanner: false,

          // Use the bleeding GitHub theme
          theme: githubDarkTheme,

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
        );
      },
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
    AppLogger.logger
        .d('🔧 Provider added: ${provider.name ?? provider.runtimeType}');
  }

  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    AppLogger.logger
        .d('🔄 Provider updated: ${provider.name ?? provider.runtimeType}');
  }

  @override
  void didDisposeProvider(
    ProviderBase<Object?> provider,
    ProviderContainer container,
  ) {
    AppLogger.logger
        .d('🗑️ Provider disposed: ${provider.name ?? provider.runtimeType}');
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

/// Error screen shown when app initialization fails
class _ErrorScreen extends StatelessWidget {
  final String title;
  final String details;
  final Object error;
  final StackTrace? stackTrace;

  const _ErrorScreen({
    required this.title,
    required this.details,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade50,
      appBar: AppBar(
        title: const Text('Initialization Error'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade700,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.red.shade900,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              details,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Restart the app
                // This is a simplified restart - in production you might want
                // to use a package like restart_app
                throw Exception('User requested app restart');
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Restart App'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            ExpansionTile(
              title: const Text('Technical Details'),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Error: ${error.toString()}',
                        style: const TextStyle(fontFamily: 'monospace'),
                      ),
                      if (stackTrace != null) ...[
                        const SizedBox(height: 8),
                        const Text('Stack Trace:'),
                        const SizedBox(height: 4),
                        Text(
                          stackTrace.toString(),
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget error fallback
class _ErrorWidget extends StatelessWidget {
  final FlutterErrorDetails errorDetails;

  const _ErrorWidget({required this.errorDetails});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red.shade100,
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error,
            color: Colors.red.shade700,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            'Widget Error',
            style: TextStyle(
              color: Colors.red.shade900,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            errorDetails.exception.toString(),
            style: TextStyle(
              color: Colors.red.shade800,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

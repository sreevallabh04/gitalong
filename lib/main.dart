import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'config/firebase_config.dart';
import 'config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/error_handler.dart';
import 'core/utils/logger.dart';
import 'providers/app_lifecycle_provider.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize logging first - critical for production debugging
  AppLogger.initialize();
  AppLogger.logger.i('🚀 GitAlong starting up...');

  // Set up global error handling before anything else
  _setupErrorHandling();

  try {
    // Initialize app configuration
    AppLogger.logger.i('⚙️ Initializing App Configuration...');
    await AppConfig.initialize();
    AppLogger.logger.success(
      'App Config initialized - Environment: ${AppConfig.environment}, Version: ${AppConfig.version}',
    );

    // Initialize Hive for local storage
    AppLogger.logger.i('💾 Initializing Hive...');
    await Hive.initFlutter();
    await Hive.openBox('app_data');
    AppLogger.logger.success('Hive initialized successfully');

    // Initialize Firebase - this is critical for authentication
    AppLogger.logger.i('🔥 About to initialize Firebase...');
    await FirebaseConfig.initialize();
    AppLogger.logger.success('Firebase initialization completed');

    AppLogger.logger.success('🎉 App initialization completed successfully');

    runApp(
      ProviderScope(
        observers: [AppProviderObserver()],
        child: const MyApp(),
      ),
    );
  } catch (e, stackTrace) {
    // Log the critical initialization error
    AppLogger.logger.e(
      '💥 CRITICAL: App initialization failed',
      error: e,
      stackTrace: stackTrace,
    );

    // Provide user-friendly error information
    String errorMessage = 'Initialization Error';
    String errorDetails = e.toString();

    if (e.toString().contains('Firebase')) {
      errorMessage = 'Firebase Configuration Error';
      errorDetails = 'Please check your Firebase setup:\n'
          '1. Ensure google-services.json is properly configured\n'
          '2. Check your internet connection\n'
          '3. Run: dart scripts/setup_firebase.dart\n\n'
          'Error: ${e.toString()}';
    } else if (e.toString().contains('Hive')) {
      errorMessage = 'Storage Initialization Error';
      errorDetails = 'Local storage could not be initialized.\n'
          'Please restart the app.\n\n'
          'Error: ${e.toString()}';
    }

    // Show minimal error app that still allows debugging
    runApp(
      MaterialApp(
        title: 'GitAlong - Error',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: _ErrorScreen(
          title: errorMessage,
          details: errorDetails,
          error: e,
          stackTrace: stackTrace,
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

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch app lifecycle
    ref.watch(appLifecycleProvider);

    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone 13 design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'GitAlong',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.dark,
          home: const SplashScreen(),
          // Global error handling for route errors
          builder: (context, widget) {
            ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
              AppLogger.logger.e(
                '🎨 Widget Error in build phase',
                error: errorDetails.exception,
                stackTrace: errorDetails.stack,
              );
              return _ErrorWidget(errorDetails: errorDetails);
            };
            return widget!;
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
    this.stackTrace,
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

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

  // Initialize logging first
  AppLogger.initialize();

  // Set up global error handling
  _setupErrorHandling();

  try {
    // Initialize app configuration
    AppConfig.initialize();
    AppLogger.logger.i(
      'App Config initialized - Environment: ${AppConfig.environment}, Version: ${AppConfig.version}',
    );

    // Initialize Hive
    await Hive.initFlutter();
    await Hive.openBox('app_data');
    AppLogger.logger.i('Hive initialized successfully');

    // Initialize Firebase
    AppLogger.logger.i('About to initialize Firebase...');
    await FirebaseConfig.initialize();
    AppLogger.logger.i('Firebase initialization completed');

    AppLogger.logger.i('App initialization completed');

    runApp(
      ProviderScope(
        observers: [AppProviderObserver()],
        child: const MyApp(),
      ),
    );
  } catch (e, stackTrace) {
    AppLogger.logger
        .e('Initialization error', error: e, stackTrace: stackTrace);
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Initialization Error: $e'),
          ),
        ),
      ),
    );
  }
}

void _setupErrorHandling() {
  // Catch Flutter framework errors
  FlutterError.onError = ErrorHandler.handleFlutterError;

  // Catch Dart errors outside Flutter framework
  PlatformDispatcher.instance.onError = ErrorHandler.handlePlatformError;
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
        .d('Provider added: ${provider.name ?? provider.runtimeType}');
  }

  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    AppLogger.logger
        .d('Provider updated: ${provider.name ?? provider.runtimeType}');
  }

  @override
  void didDisposeProvider(
    ProviderBase<Object?> provider,
    ProviderContainer container,
  ) {
    AppLogger.logger
        .d('Provider disposed: ${provider.name ?? provider.runtimeType}');
  }

  @override
  void providerDidFail(
    ProviderBase<Object?> provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    AppLogger.logger.e(
      'Provider failed: ${provider.name ?? provider.runtimeType}',
      error: error,
      stackTrace: stackTrace,
    );
  }
}

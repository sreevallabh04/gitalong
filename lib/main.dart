import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:device_preview/device_preview.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/supabase_config.dart';
import 'config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/utils/error_handler.dart';
import 'providers/app_lifecycle_provider.dart';
import 'screens/splash_screen.dart';
import 'core/utils/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize app configuration
    AppConfig.initialize();
    print(
      '✅ App Config initialized - Environment: ${AppConfig.environment}, Version: ${AppConfig.version}',
    );

    // Initialize Hive
    await Hive.initFlutter();
    await Hive.openBox('app_data');

    // Initialize Supabase
    await SupabaseConfig.initialize();

    print('✅ App initialization completed');

    runApp(
      ProviderScope(observers: [AppProviderObserver()], child: const MyApp()),
    );
  } catch (e) {
    print('❌ Initialization error: $e');
    runApp(
      MaterialApp(
        home: Scaffold(body: Center(child: Text('Initialization Error: $e'))),
      ),
    );
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch app lifecycle
    ref.watch(appLifecycleProvider);

    return MaterialApp(
      title: 'GitAlong',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: const SplashScreen(),
    );
  }
}

// Provider observer for debugging
class AppProviderObserver extends ProviderObserver {
  @override
  void didAddProvider(
    ProviderBase<Object?> provider,
    Object? value,
    ProviderContainer container,
  ) {
    print('🔄 Provider added: ${provider.name ?? provider.runtimeType}');
  }

  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    print('🔄 Provider updated: ${provider.name ?? provider.runtimeType}');
  }

  @override
  void didDisposeProvider(
    ProviderBase<Object?> provider,
    ProviderContainer container,
  ) {
    print('🗑️ Provider disposed: ${provider.name ?? provider.runtimeType}');
  }
}

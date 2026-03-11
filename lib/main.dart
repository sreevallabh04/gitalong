import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:app_links/app_links.dart';

import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/utils/logger.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/auth/auth_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Application entry point
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Supabase with PKCE flow for proper mobile OAuth
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

  // Initialize Hive
  await Hive.initFlutter();

  // Configure dependency injection
  await configureDependencies();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  AppLogger.i('GitAlong app starting...');

  runApp(const GitAlongApp());
}

/// Main application widget
class GitAlongApp extends StatefulWidget {
  const GitAlongApp({super.key});

  @override
  State<GitAlongApp> createState() => _GitAlongAppState();
}

class _GitAlongAppState extends State<GitAlongApp> {
  final _appLinks = AppLinks();

  @override
  void initState() {
    super.initState();
    _handleIncomingLinks();
  }

  /// Listen for deep links coming back from the OAuth browser
  void _handleIncomingLinks() {
    _appLinks.uriLinkStream.listen((uri) async {
      AppLogger.i('Deep link received: $uri');
      try {
        // Have Supabase process the OAuth callback URL
        await Supabase.instance.client.auth.getSessionFromUrl(uri);
        AppLogger.i('Session recovered from deep link');
      } catch (e) {
        AppLogger.e('Error recovering session from deep link', e, StackTrace.current);
      }
    });

    // Also handle the initial link if app was launched from deep link
    _appLinks.getInitialLink().then((uri) async {
      if (uri != null) {
        AppLogger.i('Initial deep link: $uri');
        try {
          await Supabase.instance.client.auth.getSessionFromUrl(uri);
        } catch (e) {
          AppLogger.e('Error recovering session from initial link', e, StackTrace.current);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(
        AppConstants.designWidth,
        AppConstants.designHeight,
      ),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return BlocProvider(
          create: (context) => getIt<AuthBloc>()..add(AuthCheckRequested()),
          child: MaterialApp.router(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,

            // Theme
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,

            // Router
            routerConfig: AppRouter.router,

            // Builder
            builder: (context, widget) {
              if (widget == null) return const SizedBox.shrink();
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: const TextScaler.linear(1.0),
                ),
                child: widget,
              );
            },
          ),
        );
      },
    );
  }
}

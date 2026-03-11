import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'injection.config.dart';

/// Global service locator instance
final GetIt getIt = GetIt.instance;

/// Configure dependency injection
@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies() async {
  // Register Supabase services
  getIt.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);
  getIt.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn());
  
  // Initialize injectable
  getIt.init();
}

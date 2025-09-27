import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection.config.dart';

/// Global service locator instance
final GetIt getIt = GetIt.instance;

/// Configures dependency injection
@InjectableInit()
Future<void> configureDependencies() async {
  getIt.init();
}

/// Service locator shortcuts for commonly used services
/// Gets a service of type T from the service locator
T inject<T extends Object>() => getIt<T>();

/// Gets a service of type T with a parameter from the service locator
T injectWithParam<T extends Object, P>(P param) => getIt<T>(param1: param);

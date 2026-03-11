import 'package:injectable/injectable.dart';
import 'package:dio/dio.dart';

/// HTTP client dependency injection module
@module
abstract class HttpModule {
  @lazySingleton
  Dio get dio => Dio();
}

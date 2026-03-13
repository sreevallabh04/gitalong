import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:dio/dio.dart';

import '../../core/utils/logger.dart';

@module
abstract class HttpModule {
  @lazySingleton
  Dio get dio {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(
        InterceptorsWrapper(
          onError: (error, handler) {
            AppLogger.w(
              'Dio error [${error.response?.statusCode}] ${error.requestOptions.uri}',
            );
            handler.next(error);
          },
        ),
      );
    }

    return dio;
  }
}

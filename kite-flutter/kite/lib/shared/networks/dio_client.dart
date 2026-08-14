import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:kite/shared/networks/auth_interceptor.dart';
import 'package:kite/shared/networks/jwt_service.dart';

class DioClient {
  late final Dio _dio;

  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8080/kite/api/v1';
    if (Platform.isAndroid) return 'http://10.0.2.2:8080/kite/api/v1';
    return 'http://localhost:8080/kite/api/v1';
  }

  DioClient(JwtService jwtService) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(AuthInterceptor(jwtService, _dio));

    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestHeader: true,
          requestBody: true,
          responseHeader: false,
          responseBody: true,
          error: true,
        ),
      );
    }
  }

  Dio get dio => _dio;
}

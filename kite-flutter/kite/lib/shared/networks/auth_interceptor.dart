import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:kite/shared/networks/jwt_service.dart';

class AuthInterceptor extends Interceptor {
  final JwtService _jwtService;
  final Dio _dio;

  AuthInterceptor(this._jwtService, this._dio);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final path = options.path;
    final isAuthEndpoint = path.contains('/auth/login') ||
        path.contains('/auth/sign-up') ||
        path.contains('/auth/refresh') ||
        options.extra['no_auth'] == true;

    if (!isAuthEndpoint) {
      final token = await _jwtService.getToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    options.headers['Content-Type'] = 'application/json';
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final path = err.requestOptions.path;
    final isAuthEndpoint = path.contains('/auth/login') ||
        path.contains('/auth/sign-up') ||
        path.contains('/auth/refresh');

    if (err.response?.statusCode == 401 && !isAuthEndpoint) {
      final isRetried = err.requestOptions.extra['retried'] == true;
      if (!isRetried) {
        err.requestOptions.extra['retried'] = true;
        try {
          final refreshToken = await _jwtService.getRefreshToken();
          if (refreshToken != null && refreshToken.isNotEmpty) {
            debugPrint('JWT expired (401). Attempting automatic token refresh...');
            final refreshResponse = await _dio.post(
              '/auth/refresh',
              data: {'refreshToken': refreshToken},
              options: Options(extra: {'no_auth': true}),
            );

            if (refreshResponse.statusCode == 200 && refreshResponse.data is Map) {
              final String? newJwt = refreshResponse.data['token'] as String?;
              final String? newRefreshToken = refreshResponse.data['refreshToken'] as String?;

              if (newJwt != null && newJwt.isNotEmpty) {
                await _jwtService.saveTokens(jwt: newJwt, refreshToken: newRefreshToken);
                debugPrint('JWT refreshed successfully!');

                err.requestOptions.headers['Authorization'] = 'Bearer $newJwt';
                final response = await _dio.fetch(err.requestOptions);
                return handler.resolve(response);
              }
            }
          }
        } catch (e) {
          debugPrint('Auto-refresh token failed: $e. Clearing tokens.');
          await _jwtService.clearTokens();
        }
      }
    }
    return handler.next(err);
  }
}

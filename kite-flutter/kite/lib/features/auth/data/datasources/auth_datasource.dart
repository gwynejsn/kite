import 'package:dio/dio.dart';
import 'package:kite/features/auth/data/dto/register_request.dart';
import 'package:kite/shared/exceptions/authentication_exception.dart';

class AuthDataSource {
  final Dio dio;

  AuthDataSource(this.dio);

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      throw AuthenticationException('Invalid response format from server', 500);
    } on DioException catch (e) {
      final message = _extractErrorMessage(e, fallback: 'Authentication failed');
      throw AuthenticationException(message, e.response?.statusCode ?? 0);
    }
  }

  Future<String> register(RegisterRequest registerRequest) async {
    try {
      final response = await dio.post(
        '/auth/sign-up',
        data: registerRequest.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data.toString();
      }
      throw AuthenticationException('Registration failed', response.statusCode ?? 500);
    } on DioException catch (e) {
      final message = _extractErrorMessage(e, fallback: 'Registration failed');
      throw AuthenticationException(message, e.response?.statusCode ?? 0);
    }
  }

  Future<void> logout(String refreshToken) async {
    try {
      await dio.post(
        '/auth/logout',
        data: {'refreshToken': refreshToken},
      );
    } on DioException catch (e) {
      final message = _extractErrorMessage(e, fallback: 'Logout failed');
      throw AuthenticationException(message, e.response?.statusCode ?? 0);
    }
  }

  String _extractErrorMessage(DioException e, {required String fallback}) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return 'Cannot connect to server. Please check your connection.';
    }
    if (e.response?.data is Map && (e.response?.data as Map)['message'] != null) {
      return (e.response?.data as Map)['message'].toString();
    }
    return fallback;
  }
}

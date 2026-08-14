import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kite/shared/networks/jwt_service.dart';

class JwtServiceImp implements JwtService {
  final FlutterSecureStorage _flutterSecureStorage;

  JwtServiceImp() : _flutterSecureStorage = const FlutterSecureStorage();

  @override
  Future<void> saveTokens({String? jwt, String? refreshToken}) async {
    if (jwt != null && jwt.isNotEmpty) {
      final cleanJwt = jwt.trim().replaceAll('"', '').replaceAll('\n', '').replaceAll('\r', '');
      await _flutterSecureStorage.write(key: 'jwt', value: cleanJwt);
    }
    if (refreshToken != null && refreshToken.isNotEmpty) {
      final cleanRefresh = refreshToken.trim().replaceAll('"', '').replaceAll('\n', '').replaceAll('\r', '');
      await _flutterSecureStorage.write(key: 'refresh_token', value: cleanRefresh);
    }
  }

  @override
  Future<void> saveToken(String? jwt) async {
    if (jwt != null && jwt.isNotEmpty) {
      final cleanJwt = jwt.trim().replaceAll('"', '').replaceAll('\n', '').replaceAll('\r', '');
      await _flutterSecureStorage.write(key: 'jwt', value: cleanJwt);
    } else {
      await _flutterSecureStorage.delete(key: 'jwt');
    }
  }

  @override
  Future<void> saveRefreshToken(String? refreshToken) async {
    if (refreshToken != null && refreshToken.isNotEmpty) {
      final cleanRefresh = refreshToken.trim().replaceAll('"', '').replaceAll('\n', '').replaceAll('\r', '');
      await _flutterSecureStorage.write(key: 'refresh_token', value: cleanRefresh);
    } else {
      await _flutterSecureStorage.delete(key: 'refresh_token');
    }
  }

  @override
  Future<String?> getToken() async {
    final token = await _flutterSecureStorage.read(key: 'jwt');
    return token?.trim().replaceAll('"', '').replaceAll('\n', '').replaceAll('\r', '');
  }

  @override
  Future<String?> getRefreshToken() async {
    final token = await _flutterSecureStorage.read(key: 'refresh_token');
    return token?.trim().replaceAll('"', '').replaceAll('\n', '').replaceAll('\r', '');
  }

  @override
  Future<void> clearTokens() async {
    await _flutterSecureStorage.delete(key: 'jwt');
    await _flutterSecureStorage.delete(key: 'refresh_token');
  }
}

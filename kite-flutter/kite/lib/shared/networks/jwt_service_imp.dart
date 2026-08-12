import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kite/shared/exceptions/authentication_exception.dart';
import 'package:kite/shared/networks/jwt_service.dart';

class JwtServiceImp implements JwtService {
  final FlutterSecureStorage _flutterSecureStorage;

  JwtServiceImp() : _flutterSecureStorage = FlutterSecureStorage();

  @override
  Future<void> saveToken(String? jwt) async {
    if (jwt != null && jwt.isNotEmpty) {
      await _flutterSecureStorage.write(key: 'jwt', value: jwt);
    }
  }

  @override
  Future<String> getToken() async {
    String? token = await _flutterSecureStorage.read(key: 'jwt');
    if (token == null) {
      throw AuthenticationException("JWT not found or expired!", 401);
    }
    return token;
  }
}

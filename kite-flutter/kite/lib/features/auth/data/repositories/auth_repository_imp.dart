import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kite/features/auth/data/datasources/auth_data_source.dart';
import 'package:kite/features/auth/data/dto/register_request.dart';
import 'package:kite/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource authDataSource;
  final FlutterSecureStorage _flutterSecureStorage;

  AuthRepositoryImpl(this.authDataSource)
    : _flutterSecureStorage = FlutterSecureStorage();

  @override
  Future<void> login({required String email, required String password}) async {
    final Map<String, dynamic> result = await authDataSource.login(
      email,
      password,
    );

    final String? token = result['jwtToken'] as String?;
    _saveToken(token);
  }

  @override
  Future<void> register(RegisterRequest registerRequest) async {
    String? token = await authDataSource.register(registerRequest);
    _saveToken(token);
  }

  void _saveToken(String? jwt) {
    if (jwt != null && jwt.isNotEmpty) {
      _flutterSecureStorage.write(key: 'jwt', value: jwt);
    }
  }
}

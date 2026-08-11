import 'package:kite/core/networks/jwt_service.dart';
import 'package:kite/features/auth/data/datasources/auth_data_source.dart';
import 'package:kite/features/auth/data/dto/register_request.dart';
import 'package:kite/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource _authDataSource;
  final JwtService _jwtService;

  AuthRepositoryImpl(this._authDataSource, this._jwtService);

  @override
  Future<void> login({required String email, required String password}) async {
    final Map<String, dynamic> result = await _authDataSource.login(
      email,
      password,
    );

    final String? token = result['jwtToken'] as String?;
    _jwtService.saveToken(token);
  }

  @override
  Future<void> register(RegisterRequest registerRequest) async {
    String? token = await _authDataSource.register(registerRequest);
    _jwtService.saveToken(token);
  }
}

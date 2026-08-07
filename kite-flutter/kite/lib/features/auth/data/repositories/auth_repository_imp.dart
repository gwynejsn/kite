import 'package:kite/features/auth/data/datasources/auth_data_source.dart';
import 'package:kite/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource authDataSource;

  AuthRepositoryImpl(this.authDataSource);

  @override
  Future<bool> login({required String email, required String password}) async {
    final Map<String, dynamic> result = await authDataSource.login(
      email,
      password,
    );

    final String? token = result['jwtToken'] as String?;

    return token != null && token.isNotEmpty;
  }
}

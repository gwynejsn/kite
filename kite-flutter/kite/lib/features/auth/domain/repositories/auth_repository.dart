import 'package:kite/features/auth/data/dto/register_request.dart';

abstract interface class AuthRepository {
  Future<void> login({required String email, required String password});
  Future<void> register(RegisterRequest registerRequest);
  Future<void> logout();
}

import 'package:flutter/rendering.dart';
import 'package:kite/features/auth/data/datasources/auth_data_source.dart';
import 'package:kite/features/auth/data/dto/register_request.dart';
import 'package:kite/features/auth/domain/repositories/auth_repository.dart';
import 'package:kite/shared/networks/jwt_service.dart';
import 'package:kite/shared/security/encryption_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource _authDataSource;
  final JwtService _jwtService;
  final EncryptionService _encryptionService;

  AuthRepositoryImpl(
    this._authDataSource,
    this._jwtService,
    this._encryptionService,
  );

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
    final publicKeyGenerated = await _encryptionService.initAndGetPublicKey();
    // add the public key
    debugPrint('this is my public key $publicKeyGenerated');
    String? token = await _authDataSource.register(
      registerRequest.copyWith(publicKey: publicKeyGenerated.toString()),
    );
    _jwtService.saveToken(token);
  }
}

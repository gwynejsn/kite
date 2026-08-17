import 'package:flutter/rendering.dart';
import 'package:kite/features/auth/data/datasources/auth_datasource.dart';
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
    await _encryptionService.initAndGetPublicKey();

    final Map<String, dynamic> result = await _authDataSource.login(
      email,
      password,
    );

    final String? token = result['token'] as String? ?? result['jwtToken'] as String?;
    final String? refreshToken = result['refreshToken'] as String?;
    await _jwtService.saveTokens(jwt: token, refreshToken: refreshToken);
  }

  @override
  Future<void> register(RegisterRequest registerRequest) async {
    final publicKeyGenerated = await _encryptionService.initAndGetPublicKey();
    debugPrint('this is my public key $publicKeyGenerated');
    String? token = await _authDataSource.register(
      registerRequest.copyWith(publicKey: publicKeyGenerated.toString()),
    );
    await _jwtService.saveToken(token);
  }

  @override
  Future<void> logout() async {
    try {
      final refreshToken = await _jwtService.getRefreshToken();
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await _authDataSource.logout(refreshToken);
      }
    } catch (e) {
      debugPrint('Error revoking refresh token on logout: $e');
    } finally {
      await _jwtService.clearTokens();
    }
  }
}

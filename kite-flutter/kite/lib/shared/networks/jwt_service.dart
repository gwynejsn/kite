abstract class JwtService {
  Future<void> saveTokens({String? jwt, String? refreshToken});
  Future<void> saveToken(String? jwt);
  Future<void> saveRefreshToken(String? refreshToken);
  Future<String?> getToken();
  Future<String?> getRefreshToken();
  Future<void> clearTokens();
}

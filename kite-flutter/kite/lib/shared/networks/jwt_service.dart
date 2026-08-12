abstract class JwtService {
  // save and update are the same
  Future<void> saveToken(String? jwt);
  Future<String?> getToken();
}

abstract interface class AuthRepository {
  Future<bool> login({required String email, required String password});
}

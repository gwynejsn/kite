import 'package:flutter/foundation.dart';
import 'package:kite/core/exceptions/authentication_exception.dart';
import 'package:kite/features/auth/domain/repositories/auth_repository.dart';

import 'login_state.dart';

class LoginController extends ValueNotifier<LoginState> {
  final AuthRepository _authRepository;

  LoginController(this._authRepository) : super(const LoginState());

  Future<void> login(String email, String password) async {
    value = const LoginState(isLoading: true);

    try {
      await _authRepository.login(email: email, password: password);
      value = const LoginState(isSuccess: true);
    } on AuthenticationException catch (e) {
      value = LoginState(errorMessage: e.message);
    } catch (e) {
      value = LoginState(errorMessage: e.toString());
    }
  }
}

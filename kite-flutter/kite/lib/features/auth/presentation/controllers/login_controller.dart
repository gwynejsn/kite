import 'package:flutter/foundation.dart';
import 'package:kite/core/exceptions/authentication_exception.dart';
import 'package:kite/features/auth/domain/repositories/auth_repository.dart';

import 'login_state.dart';

class LoginController extends ValueNotifier<LoginState> {
  final AuthRepository _authRepository;

  // we pass to value notifier the initial state
  LoginController(this._authRepository) : super(const LoginState());

  Future<void> login(String email, String password) async {
    // this value is from value notifier
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

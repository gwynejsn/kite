import 'package:flutter/material.dart';
import 'package:kite/features/auth/domain/repositories/auth_repository.dart';
import 'package:kite/features/auth/presentation/controllers/register_state.dart';
import 'package:kite/shared/enums/gender.dart';
import 'package:kite/shared/exceptions/authentication_exception.dart';

class RegisterController extends ValueNotifier<RegisterState> {
  final AuthRepository _authRepository;

  RegisterController(this._authRepository) : super(const RegisterState());

  void updateEmail(String email) {
    value = value.copyWith(request: value.request.copyWith(email: email));
  }

  void updatePassword(String password) {
    value = value.copyWith(request: value.request.copyWith(password: password));
  }

  void updateFirstName(String firstName) {
    value = value.copyWith(
      request: value.request.copyWith(firstName: firstName),
    );
  }

  void updateLastName(String lastName) {
    value = value.copyWith(request: value.request.copyWith(lastName: lastName));
  }

  void updateBio(String bio) {
    value = value.copyWith(request: value.request.copyWith(bio: bio));
  }

  void updateGender(Gender gender) {
    value = value.copyWith(request: value.request.copyWith(gender: gender));
  }

  void nextStep() {
    if (value.stepIndex < 2) {
      value = value.copyWith(
        stepIndex: value.stepIndex + 1,
        errorMessage: null,
      );
    }
  }

  void previousStep() {
    if (value.stepIndex > 0) {
      value = value.copyWith(
        stepIndex: value.stepIndex - 1,
        errorMessage: null,
      );
    }
  }

  Future<void> register() async {
    value = value.copyWith(isLoading: true, errorMessage: null);

    try {
      await _authRepository.register(value.request);
      value = value.copyWith(isLoading: false, isSuccess: true);
    } on AuthenticationException catch (e) {
      value = value.copyWith(isLoading: false, errorMessage: e.message);
    } catch (e) {
      value = value.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

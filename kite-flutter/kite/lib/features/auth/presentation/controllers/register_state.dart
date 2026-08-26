import 'package:flutter/foundation.dart';
import 'package:kite/features/auth/data/dto/register_request.dart';

class RegisterState {
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;
  final int stepIndex;
  final RegisterRequest request;
  final Uint8List? profileImageBytes;
  final String? profileImageName;

  const RegisterState({
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
    this.stepIndex = 0,
    this.request = const RegisterRequest(),
    this.profileImageBytes,
    this.profileImageName,
  });

  RegisterState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
    int? stepIndex,
    RegisterRequest? request,
    Uint8List? profileImageBytes,
    String? profileImageName,
  }) {
    return RegisterState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
      stepIndex: stepIndex ?? this.stepIndex,
      request: request ?? this.request,
      profileImageBytes: profileImageBytes ?? this.profileImageBytes,
      profileImageName: profileImageName ?? this.profileImageName,
    );
  }
}

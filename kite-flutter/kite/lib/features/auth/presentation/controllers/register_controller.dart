import 'package:flutter/foundation.dart';
import 'package:kite/features/auth/domain/repositories/auth_repository.dart';
import 'package:kite/features/auth/presentation/controllers/register_state.dart';
import 'package:kite/features/media/domain/repositories/media_repository.dart';
import 'package:kite/shared/di/injection_container.dart';
import 'package:kite/shared/enums/gender.dart';
import 'package:kite/shared/exceptions/authentication_exception.dart';

class RegisterController extends ValueNotifier<RegisterState> {
  final AuthRepository _authRepository;
  final MediaRepository? mediaRepository;

  RegisterController(
    this._authRepository, {
    this.mediaRepository,
  }) : super(const RegisterState());

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

  void updateProfileImage(Uint8List bytes, String fileName) {
    value = value.copyWith(
      profileImageBytes: bytes,
      profileImageName: fileName,
    );
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
      var currentRequest = value.request;

      // Upload profile image (unencrypted) if user selected one
      if (value.profileImageBytes != null && value.profileImageName != null) {
        final mediaRepo = mediaRepository ?? sl<MediaRepository>();
        final imageUrl = await mediaRepo.uploadUnencryptedMedia(
          rawBytes: value.profileImageBytes!,
          fileName: value.profileImageName!,
        );
        currentRequest = currentRequest.copyWith(profileImageLink: imageUrl);
      }

      await _authRepository.register(currentRequest);
      value = value.copyWith(
        isLoading: false,
        isSuccess: true,
        request: currentRequest,
      );
    } on AuthenticationException catch (e) {
      value = value.copyWith(isLoading: false, errorMessage: e.message);
    } catch (e) {
      value = value.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

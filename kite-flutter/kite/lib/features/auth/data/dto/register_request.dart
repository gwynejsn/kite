import 'package:kite/shared/enums/gender.dart';

class RegisterRequest {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String profileImageLink;
  final String bio;
  final Gender gender;
  final String publicKey;

  const RegisterRequest({
    this.email = '',
    this.password = '',
    this.firstName = '',
    this.lastName = '',
    this.profileImageLink = '',
    this.bio = '',
    this.gender = Gender.other,
    this.publicKey = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      'profileImageLink': profileImageLink,
      'bio': bio,
      'gender': gender.name.toUpperCase(),
      'publicKey': publicKey,
    };
  }

  RegisterRequest copyWith({
    String? email,
    String? password,
    String? firstName,
    String? lastName,
    String? profileImageLink,
    String? bio,
    Gender? gender,
    String? publicKey,
  }) {
    return RegisterRequest(
      email: email ?? this.email,
      password: password ?? this.password,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      profileImageLink: profileImageLink ?? this.profileImageLink,
      bio: bio ?? this.bio,
      gender: gender ?? this.gender,
      publicKey: publicKey ?? this.publicKey,
    );
  }
}

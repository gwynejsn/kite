import 'package:kite/shared/enums/gender.dart';
import 'package:kite/shared/enums/preferred_theme.dart';

class UserProfile {
  final String userId;
  final String firstName;
  final String lastName;
  final String username;
  final String profileImageLink;
  final String bio;
  final Gender gender;
  final PreferredTheme preferredTheme;

  UserProfile({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.profileImageLink,
    required this.bio,
    required this.gender,
    required this.preferredTheme,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      username: json['username'] ?? '',
      profileImageLink: json['profileImageLink'] ?? '',
      bio: json['bio'] ?? '',
      gender: Gender.values.firstWhere(
        (g) => g.name.toUpperCase() == (json['gender'] as String?).toString().toUpperCase(),
        orElse: () => Gender.other,
      ),
      preferredTheme: PreferredTheme.values.firstWhere(
        (t) => t.name.toUpperCase() == (json['preferredTheme'] as String?).toString().toUpperCase(),
        orElse: () => PreferredTheme.system,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      'username': username,
      'profileImageLink': profileImageLink,
      'bio': bio,
      'gender': gender.name.toUpperCase(),
      'preferredTheme': preferredTheme.name.toUpperCase(),
    };
  }
}

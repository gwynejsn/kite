import 'package:kite/features/social/domain/relation_status.dart';

class UserDiscovery {
  final String userId;
  final String firstName;
  final String lastName;
  final String username;
  final String profileImageLink;
  final String bio;
  final RelationStatus? relationStatus;
  final bool? isRequester;
  final String? relationId;
  final String? publicKey;
  final bool blocked;

  const UserDiscovery({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.profileImageLink,
    required this.bio,
    this.relationStatus,
    this.isRequester,
    this.relationId,
    this.publicKey,
    this.blocked = false,
  });

  factory UserDiscovery.fromJson(Map<String, dynamic> json) {
    return UserDiscovery(
      userId: json['userId'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      username: json['username'] ?? '',
      profileImageLink: json['profileImageLink'] ?? '',
      bio: json['bio'] ?? '',
      relationStatus: json['relationStatus'] != null
          ? RelationStatus.values.firstWhere(
              (s) => s.name.toUpperCase() == (json['relationStatus'] as String?).toString().toUpperCase(),
              orElse: () => RelationStatus.pending,
            )
          : null,
      isRequester: json['isRequester'] as bool?,
      relationId: json['relationId'] as String?,
      publicKey: json['publicKey'] as String?,
      blocked: json['blocked'] as bool? ?? false,
    );
  }
}

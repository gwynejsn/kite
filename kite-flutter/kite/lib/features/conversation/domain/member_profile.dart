class MemberProfile {
  final String id;
  final String firstName;
  final String lastName;
  final String username;
  final String? profilePhoto;

  const MemberProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    this.profilePhoto,
  });

  String get displayName {
    final fullName = '$firstName $lastName'.trim();
    return fullName.isNotEmpty ? fullName : username;
  }

  String get initials {
    final name = displayName.trim();
    if (name.isEmpty) return 'U';
    final parts = name.split(RegExp(r'\s+'));
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  factory MemberProfile.fromJson(Map<String, dynamic> json) {
    return MemberProfile(
      id: json['id']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      profilePhoto: json['profilePhoto'] as String?,
    );
  }
}

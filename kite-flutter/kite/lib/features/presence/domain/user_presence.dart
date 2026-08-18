enum PresenceStatus { online, offline, away }

class UserPresence {
  final String userId;
  final PresenceStatus status;
  final DateTime? lastSeenAt;
  final DateTime? updatedAt;

  const UserPresence({
    required this.userId,
    required this.status,
    this.lastSeenAt,
    this.updatedAt,
  });

  bool get isOnline => status == PresenceStatus.online;

  factory UserPresence.fromJson(Map<String, dynamic> json) {
    String uId = '';
    if (json['userId'] is Map) {
      uId = json['userId']['id']?.toString() ?? '';
    } else if (json['userId'] != null) {
      uId = json['userId'].toString();
    }

    return UserPresence(
      userId: uId,
      status: PresenceStatus.values.firstWhere(
        (s) =>
            s.name.toUpperCase() ==
            (json['status'] as String?).toString().toUpperCase(),
        orElse: () => PresenceStatus.offline,
      ),
      lastSeenAt: json['lastSeenAt'] != null
          ? DateTime.tryParse(json['lastSeenAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'status': status.name.toUpperCase(),
      if (lastSeenAt != null) 'lastSeenAt': lastSeenAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }
}

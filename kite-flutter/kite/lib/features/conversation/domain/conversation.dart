import 'package:flutter/foundation.dart';
import 'package:kite/features/conversation/domain/conversation_type.dart';
import 'package:kite/features/conversation/domain/last_message.dart';
import 'package:kite/features/conversation/domain/member_profile.dart';
import 'package:kite/shared/security/encryption_service.dart';

class Conversation {
  final String id;
  final ConversationType type;
  final String? name;
  final String? conversationPhoto;
  final Set<String> memberIds;
  final Set<String> adminIds;
  final Map<String, MemberProfile> memberProfiles;
  final Map<String, String> memberPublicKeys;
  final Map<String, String> groupKeyMap;
  final LastMessage? lastMessage;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Conversation({
    required this.id,
    required this.type,
    this.name,
    this.conversationPhoto,
    required this.memberIds,
    required this.adminIds,
    this.memberProfiles = const {},
    this.memberPublicKeys = const {},
    this.groupKeyMap = const {},
    this.lastMessage,
    required this.createdAt,
    required this.updatedAt,
  });

  static String _parseId(dynamic obj) {
    if (obj is Map) {
      return obj['id']?.toString() ?? '';
    }
    return obj?.toString() ?? '';
  }

  static Set<String> _parseIdSet(dynamic list) {
    if (list is List) {
      return list
          .map((item) => _parseId(item))
          .where((id) => id.isNotEmpty)
          .toSet();
    }
    return {};
  }

  static Map<String, String> _parseMap(dynamic obj) {
    if (obj is Map) {
      final Map<String, String> map = {};
      obj.forEach((key, value) {
        if (key != null && value != null) {
          map[key.toString()] = value.toString();
        }
      });
      return map;
    }
    return {};
  }

  static Map<String, MemberProfile> _parseProfilesMap(dynamic obj) {
    if (obj is Map) {
      final Map<String, MemberProfile> map = {};
      obj.forEach((key, value) {
        if (key != null && value is Map) {
          map[key.toString()] =
              MemberProfile.fromJson(value as Map<String, dynamic>);
        }
      });
      return map;
    }
    return {};
  }

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: _parseId(json['id']),
      type: ConversationType.values.firstWhere(
        (t) =>
            t.name.toUpperCase() ==
            (json['type'] as String?).toString().toUpperCase(),
        orElse: () => ConversationType.direct,
      ),
      name: json['name'] as String?,
      conversationPhoto: json['conversationPhoto'] as String?,
      memberIds: _parseIdSet(json['memberIds']),
      adminIds: _parseIdSet(json['adminIds']),
      memberProfiles: _parseProfilesMap(json['memberProfiles']),
      memberPublicKeys: _parseMap(json['memberPublicKeys']),
      groupKeyMap: _parseMap(json['groupKeyMap']),
      lastMessage: json['lastMessage'] != null
          ? LastMessage.fromJson(json['lastMessage'] as Map<String, dynamic>)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Conversation copyWith({
    String? id,
    ConversationType? type,
    String? name,
    String? conversationPhoto,
    Set<String>? memberIds,
    Set<String>? adminIds,
    Map<String, MemberProfile>? memberProfiles,
    Map<String, String>? memberPublicKeys,
    LastMessage? lastMessage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Conversation(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      conversationPhoto: conversationPhoto ?? this.conversationPhoto,
      memberIds: memberIds ?? this.memberIds,
      adminIds: adminIds ?? this.adminIds,
      memberProfiles: memberProfiles ?? this.memberProfiles,
      memberPublicKeys: memberPublicKeys ?? this.memberPublicKeys,
      lastMessage: lastMessage ?? this.lastMessage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Future<String?> getGroupKey(
    EncryptionService encryptionService, {
    String? currentUserId,
  }) async {
    if (type != ConversationType.group || groupKeyMap.isEmpty) return null;
    if (currentUserId != null && groupKeyMap.containsKey(currentUserId)) {
      final encryptedGroupKey = groupKeyMap[currentUserId]!;
      try {
        return await encryptionService.decryptGroupKey(
          encryptedGroupKey: encryptedGroupKey,
        );
      } catch (e) {
        debugPrint('Failed to decrypt group key for user $currentUserId: $e');
      }
    }
    for (final entry in groupKeyMap.entries) {
      if (entry.key == currentUserId) continue;
      try {
        return await encryptionService.decryptGroupKey(
          encryptedGroupKey: entry.value,
        );
      } catch (_) {}
    }
    return null;
  }
}

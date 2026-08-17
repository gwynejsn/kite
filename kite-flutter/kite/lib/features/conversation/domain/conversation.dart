import 'package:kite/features/conversation/domain/conversation_type.dart';
import 'package:kite/features/conversation/domain/last_message.dart';

class Conversation {
  final String id;
  final ConversationType type;
  final String? name;
  final String? conversationPhoto;
  final Set<String> memberIds;
  final Set<String> adminIds;
  final Map<String, String> memberPublicKeys;
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
    this.memberPublicKeys = const {},
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
      memberPublicKeys: _parseMap(json['memberPublicKeys']),
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
      memberPublicKeys: memberPublicKeys ?? this.memberPublicKeys,
      lastMessage: lastMessage ?? this.lastMessage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

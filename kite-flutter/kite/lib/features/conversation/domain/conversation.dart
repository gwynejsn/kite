import 'package:kite/features/conversation/domain/conversation_type.dart';
import 'package:kite/features/conversation/domain/last_message.dart';

class Conversation {
  final String id;
  final ConversationType type;
  final String? name;
  final String? conversationPhoto;
  final Set<String> memberIds;
  final Set<String> adminIds;
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
    this.lastMessage,
    required this.createdAt,
    required this.updatedAt,
  });

  Conversation copyWith({
    String? id,
    ConversationType? type,
    String? name,
    String? conversationPhoto,
    Set<String>? memberIds,
    Set<String>? adminIds,
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
      lastMessage: lastMessage ?? this.lastMessage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

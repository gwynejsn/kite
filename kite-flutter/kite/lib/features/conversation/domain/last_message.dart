import 'package:kite/features/conversation/domain/message_type.dart';

class LastMessage {
  final String messageId;
  final String senderId;
  final String content;
  final MessageType messageType;
  final DateTime timestamp;

  const LastMessage({
    required this.messageId,
    required this.senderId,
    required this.content,
    required this.messageType,
    required this.timestamp,
  });

  LastMessage copyWith({
    String? messageId,
    String? senderId,
    String? content,
    MessageType? messageType,
    DateTime? timestamp,
  }) {
    return LastMessage(
      messageId: messageId ?? this.messageId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      messageType: messageType ?? this.messageType,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

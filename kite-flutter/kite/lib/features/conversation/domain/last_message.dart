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

  static String _parseId(dynamic obj) {
    if (obj is Map) {
      return obj['id']?.toString() ?? '';
    }
    return obj?.toString() ?? '';
  }

  factory LastMessage.fromJson(Map<String, dynamic> json) {
    return LastMessage(
      messageId: _parseId(json['messageId']),
      senderId: _parseId(json['senderId']),
      content: json['content'] as String? ?? '',
      messageType: MessageType.values.firstWhere(
        (m) => m.name.toUpperCase() == (json['messageType'] as String?).toString().toUpperCase(),
        orElse: () => MessageType.text,
      ),
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

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

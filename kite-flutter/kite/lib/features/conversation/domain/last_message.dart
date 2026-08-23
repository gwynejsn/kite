import 'package:kite/features/conversation/domain/encrypted_payload.dart';
import 'package:kite/features/conversation/domain/message_type.dart';
import 'package:kite/shared/security/encryption_service.dart';

class LastMessage {
  final String messageId;
  final String senderId;
  final EncryptedPayload? encryptedPayload;
  final String content;
  final MessageType messageType;
  final DateTime timestamp;

  const LastMessage({
    required this.messageId,
    required this.senderId,
    this.encryptedPayload,
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
    EncryptedPayload? payload;
    if (json['encryptedPayload'] != null) {
      payload = EncryptedPayload.fromJson(
        json['encryptedPayload'] as Map<String, dynamic>,
      );
    }

    String textContent = json['content'] as String? ?? '';
    if (textContent.isEmpty && payload != null) {
      textContent = payload.cipherText;
    }

    return LastMessage(
      messageId: _parseId(json['messageId']),
      senderId: _parseId(json['senderId']),
      encryptedPayload: payload,
      content: textContent,
      messageType: MessageType.values.firstWhere(
        (m) =>
            m.name.toUpperCase() ==
            (json['messageType'] as String?).toString().toUpperCase(),
        orElse: () => MessageType.text,
      ),
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Future<String> getDecryptedContent(
    EncryptionService encryptionService, {
    String? currentUserId,
    String? groupKeyBase64,
  }) async {
    if (encryptedPayload != null) {
      final decrypted = await encryptedPayload!.decrypt(
        encryptionService,
        currentUserId: currentUserId,
        groupKeyBase64: groupKeyBase64,
      );
      if (decrypted.isNotEmpty) return decrypted;
    }
    return content.isNotEmpty ? content : 'Message';
  }
}

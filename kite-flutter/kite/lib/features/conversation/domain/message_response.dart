import 'package:kite/features/conversation/domain/encrypted_payload.dart';
import 'package:kite/features/conversation/domain/message_status.dart';
import 'package:kite/features/conversation/domain/message_type.dart';
import 'package:kite/shared/security/encryption_service.dart';

class MessageResponse {
  final String? id;
  final String? conversationId;
  final String? senderId;
  final EncryptedPayload? encryptedPayload;
  final String? mediaUrl;
  final MessageType messageType;
  final MessageStatus status;
  final String? replyToMessageId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MessageResponse({
    this.id,
    this.conversationId,
    this.senderId,
    this.encryptedPayload,
    this.mediaUrl,
    required this.messageType,
    required this.status,
    this.replyToMessageId,
    required this.createdAt,
    required this.updatedAt,
  });

  String get textContent => encryptedPayload?.cipherText ?? '';

  Future<String> getDecryptedContent(
    EncryptionService encryptionService, {
    String? currentUserId,
  }) async {
    if (encryptedPayload == null) return '';
    return encryptedPayload!.decrypt(
      encryptionService,
      currentUserId: currentUserId,
    );
  }

  factory MessageResponse.fromJson(Map<String, dynamic> json) {
    final createdAt = DateTime.parse(json['createdAt'] as String).toLocal();
    return MessageResponse(
      id: json['id'] as String?,
      conversationId: json['conversationId'] as String?,
      senderId: json['senderId'] as String?,
      encryptedPayload: json['encryptedPayload'] != null
          ? EncryptedPayload.fromJson(
              json['encryptedPayload'] as Map<String, dynamic>,
            )
          : null,
      mediaUrl: json['mediaUrl'] as String?,
      messageType: MessageType.fromString(
        json['messageType'] as String? ?? 'TEXT',
      ),
      status: MessageStatus.fromString(json['status'] as String? ?? 'SENT'),
      replyToMessageId: json['replyToMessageId'] as String?,
      createdAt: json['createdAt'] != null ? createdAt : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }
}

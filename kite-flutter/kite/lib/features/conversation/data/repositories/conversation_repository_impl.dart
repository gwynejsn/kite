import 'package:flutter/foundation.dart';
import 'package:kite/features/conversation/data/datasources/conversation_datasource.dart';
import 'package:kite/features/conversation/data/datasources/conversation_websocket_datasource.dart';
import 'package:kite/features/conversation/domain/conversation.dart';
import 'package:kite/features/conversation/domain/encrypted_payload.dart';
import 'package:kite/features/conversation/domain/message_response.dart';
import 'package:kite/features/conversation/domain/message_type.dart';
import 'package:kite/features/conversation/domain/repositories/conversation_repository.dart';
import 'package:kite/shared/security/encryption_service.dart';

class ConversationRepositoryImpl implements ConversationRepository {
  final ConversationDatasource remoteDatasource;
  final ConversationWebsocketDatasource websocketDatasource;
  final EncryptionService encryptionService;

  ConversationRepositoryImpl({
    required this.remoteDatasource,
    required this.websocketDatasource,
    required this.encryptionService,
  });

  @override
  Future<List<Conversation>> getConversations() {
    return remoteDatasource.getConversations();
  }

  @override
  Future<List<MessageResponse>> getInitialMessages(String conversationId) {
    return remoteDatasource.getInitialMessages(conversationId);
  }

  @override
  Future<MessageResponse?> sendMessage({
    required String conversationId,
    required String plainText,
    String? recipientPublicKey,
    Map<String, String>? memberPublicKeys,
    MessageType messageType = MessageType.text,
    String? mediaUrl,
    String? replyToMessageId,
  }) async {
    EncryptedPayload encryptedPayload;

    try {
      final senderPublicKey = await encryptionService.initAndGetPublicKey();
      final Map<String, String> finalMemberKeys = {};

      if (memberPublicKeys != null && memberPublicKeys.isNotEmpty) {
        finalMemberKeys.addAll(memberPublicKeys);
      }

      final envelopeRes = await encryptionService.encryptEnvelope(
        plainText: plainText,
        memberPublicKeys: finalMemberKeys,
      );

      encryptedPayload = EncryptedPayload(
        cipherText: envelopeRes['cipherText'] as String? ?? plainText,
        nonce: envelopeRes['nonce'] as String?,
        mac: envelopeRes['mac'] as String?,
        senderPublicKey:
            envelopeRes['senderPublicKey'] as String? ?? senderPublicKey,
        encryptedGroupKeys:
            envelopeRes['encryptedGroupKeys'] as Map<String, String>?,
      );
    } catch (e) {
      debugPrint('Error encrypting message: $e');
      final senderPublicKey = await encryptionService.initAndGetPublicKey();
      encryptedPayload = EncryptedPayload(
        cipherText: plainText,
        senderPublicKey: senderPublicKey,
      );
    }

    return remoteDatasource.sendMessage(
      conversationId: conversationId,
      encryptedPayload: encryptedPayload,
      messageType: messageType,
      mediaUrl: mediaUrl,
      replyToMessageId: replyToMessageId,
    );
  }

  @override
  Future<void> connectWebsocket(Function()? onConnect) {
    return websocketDatasource.connect(onConnect: onConnect);
  }

  @override
  void Function({Map<String, String>? unsubscribeHeaders})? subscribeToRoom({
    required String conversationId,
    required Function(MessageResponse message) onMessageReceived,
  }) {
    return websocketDatasource.subscribeToConversation(
      conversationId: conversationId,
      onMessageReceived: onMessageReceived,
    );
  }

  @override
  void Function({Map<String, String>? unsubscribeHeaders})?
  subscribeToUserConversations({
    required String userId,
    required Function(Conversation conversation) onConversationUpdated,
  }) {
    return websocketDatasource.subscribeToUserConversations(
      userId: userId,
      onConversationUpdated: onConversationUpdated,
    );
  }

  @override
  void disconnectWebsocket() {
    websocketDatasource.disconnect();
  }
}

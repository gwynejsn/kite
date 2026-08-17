import 'package:flutter/material.dart';
import 'package:kite/features/conversation/domain/encrypted_payload.dart';
import 'package:kite/features/conversation/domain/message_response.dart';
import 'package:kite/features/conversation/domain/message_status.dart';
import 'package:kite/features/conversation/domain/message_type.dart';
import 'package:kite/features/conversation/domain/repositories/conversation_repository.dart';
import 'package:kite/features/conversation/presentation/controllers/conversation_room_state.dart';

class ConversationRoomController extends ValueNotifier<ConversationRoomState> {
  final ConversationRepository repository;
  void Function({Map<String, String>? unsubscribeHeaders})? _stompSubscription;

  ConversationRoomController(this.repository)
    : super(const ConversationRoomState());

  Future<void> initRoom(String conversationId) async {
    await fetchInitialMessages(conversationId);

    // connect WebSocket & Subscribe through repository abstraction
    await repository.connectWebsocket(() {
      _stompSubscription = repository.subscribeToRoom(
        conversationId: conversationId,
        onMessageReceived: (newMsg) {
          _onRealTimeMessageReceived(newMsg);
        },
      );
    });
  }

  void _onRealTimeMessageReceived(MessageResponse message) {
    final exists = value.messages.any((m) => m.id == message.id);
    if (exists) return;

    final updatedList = List<MessageResponse>.from(value.messages);
    final tempIndex = updatedList.indexWhere(
      (m) =>
          m.id != null &&
          m.id!.startsWith('temp_') &&
          m.senderId == message.senderId,
    );

    if (tempIndex != -1) {
      updatedList[tempIndex] = message;
    } else {
      updatedList.insert(0, message);
    }

    value = value.copyWith(messages: updatedList);
  }

  Future<void> fetchInitialMessages(String conversationId) async {
    value = value.copyWith(isLoading: true, errorMessage: null);

    try {
      final messages = await repository.getInitialMessages(conversationId);
      final sortedMessages = List<MessageResponse>.from(messages)
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      value = value.copyWith(isLoading: false, messages: sortedMessages);
    } catch (e) {
      value = value.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> sendMessage({
    required String conversationId,
    required String content,
    required String currentUserId,
    String? recipientPublicKey,
    Map<String, String>? memberPublicKeys,
  }) async {
    if (content.trim().isEmpty) return;

    final tempMessage = MessageResponse(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      conversationId: conversationId,
      senderId: currentUserId,
      encryptedPayload: EncryptedPayload(cipherText: content.trim()),
      messageType: MessageType.text,
      status: MessageStatus.sent,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // optimistic UI update: Insert newest message at index 0
    final updatedList = List<MessageResponse>.from(value.messages)
      ..insert(0, tempMessage);
    value = value.copyWith(messages: updatedList);

    try {
      final sentMessage = await repository.sendMessage(
        conversationId: conversationId,
        plainText: content.trim(),
        recipientPublicKey: recipientPublicKey,
        memberPublicKeys: memberPublicKeys,
      );

      if (sentMessage != null) {
        final finalList = value.messages.map((m) {
          if (m.id == tempMessage.id) return sentMessage;
          return m;
        }).toList();
        value = value.copyWith(messages: finalList);
      }
    } catch (e) {
      debugPrint('Failed to send message: $e');
    }
  }

  @override
  void dispose() {
    if (_stompSubscription != null) {
      _stompSubscription!();
    }
    super.dispose();
  }
}

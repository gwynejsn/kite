import 'package:flutter/material.dart';
import 'package:kite/features/conversation/domain/repositories/conversation_repository.dart';
import 'package:kite/features/conversation/presentation/controllers/conversation_room_state.dart';

class ConversationRoomController extends ValueNotifier<ConversationRoomState> {
  final ConversationRepository repository;

  ConversationRoomController(this.repository) : super(const ConversationRoomState());

  Future<void> fetchInitialMessages(String conversationId) async {
    value = value.copyWith(isLoading: true, errorMessage: null);

    try {
      final messages = await repository.getInitialMessages(conversationId);
      value = value.copyWith(isLoading: false, messages: messages);
    } catch (e) {
      value = value.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }
}

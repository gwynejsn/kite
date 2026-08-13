import 'package:flutter/foundation.dart';
import 'package:kite/features/conversation/domain/repositories/conversation_repository.dart';
import 'package:kite/features/conversation/presentation/controllers/conversation_state.dart';
import 'package:kite/shared/exceptions/authentication_exception.dart';

class ConversationController extends ValueNotifier<ConversationState> {
  final ConversationRepository _repository;

  ConversationController(this._repository) : super(const ConversationState());

  Future<void> fetchConversations() async {
    value = value.copyWith(isLoading: true, errorMessage: null);

    try {
      final conversations = await _repository.getConversations();
      value = value.copyWith(
        isLoading: false,
        conversations: conversations,
      );
    } on AuthenticationException catch (e) {
      value = value.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
    } catch (e) {
      value = value.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }
}

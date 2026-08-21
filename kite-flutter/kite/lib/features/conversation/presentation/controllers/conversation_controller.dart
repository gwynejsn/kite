import 'package:flutter/foundation.dart';
import 'package:kite/features/conversation/domain/conversation.dart';
import 'package:kite/features/conversation/domain/repositories/conversation_repository.dart';
import 'package:kite/features/conversation/presentation/controllers/conversation_state.dart';
import 'package:kite/shared/exceptions/authentication_exception.dart';

class ConversationController extends ValueNotifier<ConversationState> {
  final ConversationRepository _repository;
  void Function({Map<String, String>? unsubscribeHeaders})? _stompSubscription;

  ConversationController(this._repository) : super(const ConversationState());

  Future<void> fetchConversations({String? currentUserId}) async {
    value = value.copyWith(isLoading: true, errorMessage: null);

    try {
      final conversations = await _repository.getConversations();
      value = value.copyWith(
        isLoading: false,
        conversations: conversations,
      );

      if (currentUserId != null && currentUserId.isNotEmpty) {
        _subscribeToRealtimeUpdates(currentUserId);
      }
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

  Future<void> _subscribeToRealtimeUpdates(String userId) async {
    await _repository.connectWebsocket(() {
      _stompSubscription?.call();
      _stompSubscription = _repository.subscribeToUserConversations(
        userId: userId,
        onConversationUpdated: (updatedConv) {
          _onRealtimeConversationUpdate(updatedConv);
        },
      );
    });
  }

  void _onRealtimeConversationUpdate(Conversation updatedConv) {
    debugPrint(
      'Real-time conversation card update received for conv ID: ${updatedConv.id}',
    );
    final list = List<Conversation>.from(value.conversations);
    final index = list.indexWhere((c) => c.id == updatedConv.id);

    if (index != -1) {
      list.removeAt(index);
    }
    list.insert(0, updatedConv);

    value = value.copyWith(conversations: list);
  }

  Future<Conversation?> createGroupConversation({
    required String name,
    required List<String> memberIds,
    String? photoUrl,
    List<String>? adminIds,
  }) async {
    try {
      final newConv = await _repository.createGroupConversation(
        conversationName: name,
        memberIds: memberIds,
        conversationPhoto: photoUrl,
        adminIds: adminIds,
      );

      final list = List<Conversation>.from(value.conversations);
      final index = list.indexWhere((c) => c.id == newConv.id);
      if (index != -1) {
        list.removeAt(index);
      }
      list.insert(0, newConv);

      value = value.copyWith(conversations: list);
      return newConv;
    } on AuthenticationException catch (e) {
      value = value.copyWith(errorMessage: e.message);
      rethrow;
    } catch (e) {
      value = value.copyWith(errorMessage: e.toString());
      rethrow;
    }
  }

  @override
  void dispose() {
    _stompSubscription?.call();
    super.dispose();
  }
}

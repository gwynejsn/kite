import 'package:flutter/foundation.dart';
import 'package:kite/features/conversation/domain/conversation.dart';
import 'package:kite/features/conversation/domain/repositories/conversation_repository.dart';
import 'package:kite/features/conversation/presentation/controllers/conversation_state.dart';
import 'package:kite/shared/exceptions/authentication_exception.dart';

class ConversationController extends ValueNotifier<ConversationState> {
  final ConversationRepository _repository;
  void Function({Map<String, String>? unsubscribeHeaders})? _stompSubscription;

  String? _currentUserId;

  ConversationController(this._repository) : super(const ConversationState());

  void updateCurrentUser(String? userId) {
    if (userId != null &&
        userId.isNotEmpty &&
        (_currentUserId != userId || _stompSubscription == null)) {
      _currentUserId = userId;
      _subscribeToRealtimeUpdates(userId);
    }
  }

  Future<void> fetchConversations({String? currentUserId}) async {
    if (currentUserId != null && currentUserId.isNotEmpty) {
      _currentUserId = currentUserId;
    }
    value = value.copyWith(isLoading: true, errorMessage: null);

    try {
      final conversations = await _repository.getConversations();
      value = value.copyWith(
        isLoading: false,
        conversations: conversations,
      );

      final activeUserId = _currentUserId ?? currentUserId;
      if (activeUserId != null && activeUserId.isNotEmpty) {
        _subscribeToRealtimeUpdates(activeUserId);
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

    if (_currentUserId == null || updatedConv.memberIds.contains(_currentUserId)) {
      list.insert(0, updatedConv);
    }

    value = value.copyWith(conversations: list);
  }

  Future<Conversation?> createGroupConversation({
    required String name,
    required List<String> memberIds,
    String? photoUrl,
    List<String>? adminIds,
    Map<String, String>? groupKeyMap,
  }) async {
    try {
      final Conversation newGroup = await _repository.createGroupConversation(
        conversationName: name,
        memberIds: memberIds,
        conversationPhoto: photoUrl,
        adminIds: adminIds,
        groupKeyMap: groupKeyMap,
      );

      final list = List<Conversation>.from(value.conversations);
      final index = list.indexWhere((c) => c.id == newGroup.id);
      if (index != -1) {
        list.removeAt(index);
      }
      list.insert(0, newGroup);

      value = value.copyWith(conversations: list);
      return newGroup;
    } on AuthenticationException catch (e) {
      value = value.copyWith(errorMessage: e.message);
      rethrow;
    } catch (e) {
      value = value.copyWith(errorMessage: e.toString());
      rethrow;
    }
  }

  Future<Conversation?> addMembersToGroup({
    required String conversationId,
    required List<String> memberIds,
    Map<String, String>? groupKeyMap,
  }) async {
    try {
      final updatedConv = await _repository.addMembers(
        conversationId: conversationId,
        memberIds: memberIds,
        groupKeyMap: groupKeyMap,
      );

      _onRealtimeConversationUpdate(updatedConv);
      return updatedConv;
    } on AuthenticationException catch (e) {
      value = value.copyWith(errorMessage: e.message);
      rethrow;
    } catch (e) {
      value = value.copyWith(errorMessage: e.toString());
      rethrow;
    }
  }

  Future<Conversation?> kickMemberFromGroup({
    required String conversationId,
    required String targetMemberId,
  }) async {
    try {
      final updatedConv = await _repository.kickMember(
        conversationId: conversationId,
        targetMemberId: targetMemberId,
      );

      _onRealtimeConversationUpdate(updatedConv);
      return updatedConv;
    } on AuthenticationException catch (e) {
      value = value.copyWith(errorMessage: e.message);
      rethrow;
    } catch (e) {
      value = value.copyWith(errorMessage: e.toString());
      rethrow;
    }
  }

  Future<void> leaveGroupConversation({
    required String conversationId,
  }) async {
    try {
      await _repository.leaveGroup(conversationId: conversationId);

      final list = List<Conversation>.from(value.conversations);
      list.removeWhere((c) => c.id == conversationId);
      value = value.copyWith(conversations: list);
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

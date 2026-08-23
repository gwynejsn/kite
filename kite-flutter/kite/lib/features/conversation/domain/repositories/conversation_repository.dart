import 'package:kite/features/conversation/domain/conversation.dart';
import 'package:kite/features/conversation/domain/message_response.dart';
import 'package:kite/features/conversation/domain/message_type.dart';

abstract interface class ConversationRepository {
  Future<List<Conversation>> getConversations();

  Future<List<MessageResponse>> getInitialMessages(String conversationId);

  Future<MessageResponse?> sendMessage({
    required String conversationId,
    required String plainText,
    String? recipientPublicKey,
    Map<String, String>? memberPublicKeys,
    String? groupKeyBase64,
    MessageType messageType = MessageType.text,
    String? mediaUrl,
    String? replyToMessageId,
  });

  Future<Conversation> createGroupConversation({
    required String conversationName,
    required List<String> memberIds,
    String? conversationPhoto,
    List<String>? adminIds,
    Map<String, String>? groupKeyMap,
  });

  Future<Conversation> addMembers({
    required String conversationId,
    required List<String> memberIds,
    Map<String, String>? groupKeyMap,
  });

  Future<Conversation> kickMember({
    required String conversationId,
    required String targetMemberId,
  });

  Future<void> leaveGroup({
    required String conversationId,
  });

  Future<void> connectWebsocket(Function()? onConnect);

  void Function({Map<String, String>? unsubscribeHeaders})? subscribeToRoom({
    required String conversationId,
    required Function(MessageResponse message) onMessageReceived,
  });

  void Function({Map<String, String>? unsubscribeHeaders})? subscribeToUserConversations({
    required String userId,
    required Function(Conversation conversation) onConversationUpdated,
  });

  void disconnectWebsocket();
}

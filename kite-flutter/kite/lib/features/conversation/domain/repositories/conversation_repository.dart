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
    MessageType messageType = MessageType.text,
    String? mediaUrl,
    String? replyToMessageId,
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

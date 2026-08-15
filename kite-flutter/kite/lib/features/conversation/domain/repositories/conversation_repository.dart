import 'package:kite/features/conversation/domain/conversation.dart';
import 'package:kite/features/conversation/domain/message_response.dart';

abstract interface class ConversationRepository {
  Future<List<Conversation>> getConversations();
  Future<List<MessageResponse>> getInitialMessages(String conversationId);
}

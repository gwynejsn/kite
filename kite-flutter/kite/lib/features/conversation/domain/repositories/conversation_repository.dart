import 'package:kite/features/conversation/domain/conversation.dart';

abstract interface class ConversationRepository {
  Future<List<Conversation>> getConversations();
}

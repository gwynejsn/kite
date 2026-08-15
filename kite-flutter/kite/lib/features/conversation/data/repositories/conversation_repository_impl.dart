import 'package:kite/features/conversation/data/datasources/conversation_datasource.dart';
import 'package:kite/features/conversation/domain/conversation.dart';
import 'package:kite/features/conversation/domain/message_response.dart';
import 'package:kite/features/conversation/domain/repositories/conversation_repository.dart';

class ConversationRepositoryImpl implements ConversationRepository {
  final ConversationDatasource datasource;

  ConversationRepositoryImpl(this.datasource);

  @override
  Future<List<Conversation>> getConversations() {
    return datasource.getConversations();
  }

  @override
  Future<List<MessageResponse>> getInitialMessages(String conversationId) {
    return datasource.getInitialMessages(conversationId);
  }
}

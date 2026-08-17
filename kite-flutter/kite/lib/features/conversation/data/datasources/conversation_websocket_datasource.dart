import 'package:kite/features/conversation/domain/conversation.dart';
import 'package:kite/features/conversation/domain/message_response.dart';
import 'package:kite/shared/networks/websocket_service.dart';

class ConversationWebsocketDatasource {
  final WebsocketService _websocketService;

  ConversationWebsocketDatasource(this._websocketService);

  bool get isConnected => _websocketService.isConnected;

  Future<void> connect({Function()? onConnect}) {
    return _websocketService.connect(onConnectCallback: onConnect);
  }

  /// this is the current conversation the user is in
  void Function({Map<String, String>? unsubscribeHeaders})?
  subscribeToConversation({
    required String conversationId,
    required Function(MessageResponse message) onMessageReceived,
  }) {
    return _websocketService.subscribeToConversation(
      conversationId: conversationId,
      onMessageReceived: onMessageReceived,
    );
  }

  /// this is the conversation list
  void Function({Map<String, String>? unsubscribeHeaders})?
  subscribeToUserConversations({
    required String userId,
    required Function(Conversation conversation) onConversationUpdated,
  }) {
    return _websocketService.subscribeToUserConversations(
      userId: userId,
      onConversationUpdated: onConversationUpdated,
    );
  }

  void disconnect() {
    _websocketService.disconnect();
  }
}

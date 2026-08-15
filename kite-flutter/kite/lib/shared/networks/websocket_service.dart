import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class WebsocketService extends ChangeNotifier {
  StompClient? _stompClient;

  static String get baseUrl => 'ws://localhost:8080/ws-connect';

  void connect() {
    if (_stompClient != null) return;

    _stompClient = StompClient(
      config: StompConfig(
        url: baseUrl,
        onConnect: _onConnect,
        onWebSocketError: (dynamic error) => debugPrint('WS Error: $error'),
        onStompError: (StompFrame frame) =>
            debugPrint('STOMP Error: ${frame.body}'),
        onDisconnect: (frame) => debugPrint('Disconnected'),
      ),
    );

    _stompClient!.activate();
  }

  void _onConnect(StompFrame frame) {
    debugPrint('Successfully connected to Spring STOMP Broker via WebSockets!');
    listenToConversationList();
  }

  void listenToConversationList() {
    _stompClient?.subscribe(
      destination: '/topic/chat-list',
      callback: (StompFrame frame) {
        if (frame.body != null) {
          final Map<String, dynamic> data = jsonDecode(frame.body!);
          debugPrint('Chat List Update Received: $data');
          notifyListeners();
        }
      },
    );
  }

  void listenToChatRoom(String chatId) {
    _stompClient?.subscribe(
      destination: '/topic/chat.$chatId',
      callback: (StompFrame frame) {
        if (frame.body != null) {
          final Map<String, dynamic> messageData = jsonDecode(frame.body!);
          debugPrint('New message in room $chatId: $messageData');
        }
      },
    );
  }

  void sendMessage(String chatId, String text) {
    _stompClient?.send(
      destination: '/app/chat.send.$chatId',
      body: jsonEncode({'chatId': chatId, 'message': text}),
    );
  }

  void disconnect() {
    _stompClient?.deactivate();
    _stompClient = null;
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}

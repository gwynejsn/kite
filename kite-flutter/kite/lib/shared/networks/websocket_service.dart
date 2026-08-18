import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:kite/features/conversation/domain/conversation.dart';
import 'package:kite/features/conversation/domain/message_response.dart';
import 'package:kite/shared/networks/jwt_service.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class WebsocketService extends ChangeNotifier {
  final JwtService _jwtService;
  StompClient? _stompClient;
  bool _isConnected = false;

  WebsocketService(this._jwtService);

  bool get isConnected => _isConnected;

  static String get baseUrl {
    if (kIsWeb) return 'ws://localhost:8080/kite/api/v1/ws-connect';
    if (Platform.isAndroid) return 'ws://10.0.2.2:8080/kite/api/v1/ws-connect';
    return 'ws://localhost:8080/kite/api/v1/ws-connect';
  }

  Future<void> connect({Function()? onConnectCallback}) async {
    if (_isConnected && _stompClient != null) {
      if (onConnectCallback != null) onConnectCallback();
      return;
    }

    final token = await _jwtService.getToken();

    _stompClient = StompClient(
      config: StompConfig(
        url: baseUrl,
        onConnect: (StompFrame frame) {
          _isConnected = true;
          debugPrint('STOMP WebSocket Connected successfully!');
          notifyListeners();
          if (onConnectCallback != null) onConnectCallback();
        },
        onWebSocketError: (dynamic error) {
          _isConnected = false;
          debugPrint('STOMP WS Error: $error');
          notifyListeners();
        },
        onStompError: (StompFrame frame) {
          _isConnected = false;
          debugPrint('STOMP Error: ${frame.body}');
          notifyListeners();
        },
        onDisconnect: (StompFrame frame) {
          _isConnected = false;
          debugPrint('STOMP Disconnected');
          notifyListeners();
        },
        stompConnectHeaders: {
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        },
        webSocketConnectHeaders: {
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        },
      ),
    );

    _stompClient!.activate();
  }

  void Function({Map<String, String>? unsubscribeHeaders})?
  subscribeToConversation({
    required String conversationId,
    required Function(MessageResponse message) onMessageReceived,
  }) {
    if (_stompClient == null || !_isConnected) {
      debugPrint('Cannot subscribe: STOMP is not connected');
      return null;
    }

    return _stompClient!.subscribe(
      destination: '/topic/conversation.$conversationId',
      callback: (StompFrame frame) {
        if (frame.body != null) {
          try {
            final json = jsonDecode(frame.body!) as Map<String, dynamic>;
            final message = MessageResponse.fromJson(json);
            onMessageReceived(message);
          } catch (e) {
            debugPrint('Failed to parse STOMP message: $e');
          }
        }
      },
    );
  }

  void Function({Map<String, String>? unsubscribeHeaders})?
  subscribeToUserConversations({
    required String userId,
    required Function(Conversation conversation) onConversationUpdated,
  }) {
    if (_stompClient == null || !_isConnected) {
      debugPrint('Cannot subscribe: STOMP is not connected');
      return null;
    }

    return _stompClient!.subscribe(
      destination: '/topic/user.$userId.conversations',
      callback: (StompFrame frame) {
        if (frame.body != null) {
          try {
            final json = jsonDecode(frame.body!) as Map<String, dynamic>;
            final conversation = Conversation.fromJson(json);
            onConversationUpdated(conversation);
          } catch (e) {
            debugPrint('Failed to parse conversation STOMP update: $e');
          }
        }
      },
    );
  }

  void Function({Map<String, String>? unsubscribeHeaders})?
  subscribeToUserPresence({
    required String userId,
    required Function(Map<String, dynamic> json) onPresenceUpdated,
  }) {
    if (_stompClient == null || !_isConnected) {
      debugPrint('Cannot subscribe to presence: STOMP is not connected');
      return null;
    }

    return _stompClient!.subscribe(
      destination: '/topic/presence.$userId',
      callback: (StompFrame frame) {
        if (frame.body != null) {
          try {
            final json = jsonDecode(frame.body!) as Map<String, dynamic>;
            onPresenceUpdated(json);
          } catch (e) {
            debugPrint('Failed to parse presence STOMP update: $e');
          }
        }
      },
    );
  }

  void disconnect() {
    _stompClient?.deactivate();
    _stompClient = null;
    _isConnected = false;
    notifyListeners();
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}

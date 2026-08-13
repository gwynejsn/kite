import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:kite/features/conversation/domain/conversation.dart';
import 'package:kite/shared/exceptions/authentication_exception.dart';
import 'package:kite/shared/networks/jwt_service.dart';

class ConversationDatasource {
  final http.Client client;
  final JwtService jwtService;

  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8080/kite/api/v1/conversation';
    if (Platform.isAndroid) return 'http://10.0.2.2:8080/kite/api/v1/conversation';
    return 'http://localhost:8080/kite/api/v1/conversation';
  }

  ConversationDatasource(this.client, this.jwtService);

  Future<List<Conversation>> getConversations() async {
    try {
      final token = await jwtService.getToken();
      final response = await client.get(
        Uri.parse('$baseUrl/all'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        return list
            .map((json) => Conversation.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw AuthenticationException(
          'Failed to load conversations (${response.statusCode})',
          response.statusCode,
        );
      }
    } on SocketException {
      throw AuthenticationException(
        'Cannot connect to server. Please check your backend connection.',
        0,
      );
    }
  }
}

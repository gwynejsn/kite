import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:kite/core/authentication_exception.dart';

class AuthDataSource {
  final http.Client client;

  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8080/kite/api/v1/auth';
    if (Platform.isAndroid) return 'http://10.0.2.2:8080/kite/api/v1/auth';
    return 'http://localhost:8080/kite/api/v1/auth';
  }

  AuthDataSource(this.client);

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final Map<String, dynamic> result = jsonDecode(response.body);

      if (response.statusCode != 200) {
        final errorMessage = result['message'] ?? 'Authentication failed';
        throw AuthenticationException(errorMessage, response.statusCode);
      }

      return result;
    } on SocketException {
      throw AuthenticationException('Cannot connect to server. Please check your backend connection.', 0);
    } on FormatException {
      throw AuthenticationException('Invalid response format from server', 500);
    }
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:kite/core/exceptions/authentication_exception.dart';
import 'package:kite/features/auth/data/dto/register_request.dart';

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
      throw AuthenticationException(
        'Cannot connect to server. Please check your backend connection.',
        0,
      );
    } on FormatException {
      throw AuthenticationException('Invalid response format from server', 500);
    }
  }

  Future<String> register(RegisterRequest registerRequest) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/sign-up'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(registerRequest.toJson()),
      );

      // since the api returns only a string if success, check first if ok
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.body;
      } else {
        final Map<String, dynamic> errorResult = jsonDecode(response.body);
        final errorMessage = errorResult['message'] ?? 'Registration failed';
        throw AuthenticationException(errorMessage, response.statusCode);
      }
    } on SocketException {
      throw AuthenticationException(
        'Cannot connect to server. Please check your backend connection.',
        0,
      );
    } on FormatException {
      throw AuthenticationException('Invalid response format from server', 500);
    }
  }
}

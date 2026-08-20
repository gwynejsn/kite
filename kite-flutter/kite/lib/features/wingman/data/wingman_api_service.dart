import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:kite/features/wingman/domain/wingman_models.dart';
import 'package:kite/shared/networks/dio_client.dart';

class WingmanApiService {
  final DioClient _dioClient;

  WingmanApiService(this._dioClient);

  Future<WingmanResponse> generateReplies(WingmanRequest request) async {
    try {
      final response = await _dioClient.dio.post(
        '/wingman/ask',
        data: request.toJson(),
        options: Options(
          receiveTimeout: const Duration(seconds: 120),
          sendTimeout: const Duration(seconds: 120),
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        return WingmanResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
      }

      throw Exception('Failed to generate replies: ${response.statusCode}');
    } catch (e) {
      debugPrint('WingmanApiService Error: $e');
      rethrow;
    }
  }
}

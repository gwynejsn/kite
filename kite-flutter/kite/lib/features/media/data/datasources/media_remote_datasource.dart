import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:kite/shared/exceptions/authentication_exception.dart';

class MediaRemoteDatasource {
  final Dio dio;

  MediaRemoteDatasource(this.dio);

  /// Uploads encrypted bytes to /media/upload endpoint and returns the download path URL
  Future<String> uploadEncryptedMedia({
    required Uint8List encryptedBytes,
    required String fileName,
    required String mediaType, // "IMAGE", "VIDEO", "FILE", "AUDIO"
    required String uploaderId,
    required String conversationId,
  }) async {
    try {
      final uploadRequestJson = jsonEncode({
        'fileName': fileName,
        'mediaType': mediaType.toUpperCase(),
        'uploaderId': uploaderId,
        'conversationId': conversationId,
      });

      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          encryptedBytes,
          filename: fileName,
          contentType: DioMediaType('application', 'octet-stream'),
        ),
        'uploadRequest': MultipartFile.fromString(
          uploadRequestJson,
          contentType: DioMediaType('application', 'json'),
        ),
      });

      final response = await dio.post(
        '/media/upload',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode == 200 && response.data is Map) {
        final path = response.data['path'] as String?;
        if (path != null && path.isNotEmpty) {
          return path;
        }
      }
      throw AuthenticationException(
        'Failed to upload media (${response.statusCode})',
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      debugPrint('Media upload error: $e');
      final message = _extractErrorMessage(e, fallback: 'Failed to upload media');
      throw AuthenticationException(message, e.response?.statusCode ?? 0);
    }
  }

  /// Downloads binary encrypted media from mediaUrl (/media/download/{filename} or full path)
  Future<Uint8List> downloadEncryptedMedia(String mediaUrl) async {
    try {
      final response = await dio.get<List<int>>(
        mediaUrl,
        options: Options(
          responseType: ResponseType.bytes,
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        return Uint8List.fromList(response.data!);
      }
      throw AuthenticationException(
        'Failed to download media (${response.statusCode})',
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      debugPrint('Media download error: $e');
      final message = _extractErrorMessage(e, fallback: 'Failed to download media');
      throw AuthenticationException(message, e.response?.statusCode ?? 0);
    }
  }

  String _extractErrorMessage(DioException e, {required String fallback}) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return 'Cannot connect to media server. Please check your connection.';
    }
    if (e.response?.data is Map &&
        (e.response?.data as Map)['message'] != null) {
      return (e.response?.data as Map)['message'].toString();
    }
    return fallback;
  }
}

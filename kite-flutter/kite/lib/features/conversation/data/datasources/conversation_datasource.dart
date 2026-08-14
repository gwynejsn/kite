import 'package:dio/dio.dart';
import 'package:kite/features/conversation/domain/conversation.dart';
import 'package:kite/shared/exceptions/authentication_exception.dart';

class ConversationDatasource {
  final Dio dio;

  ConversationDatasource(this.dio);

  Future<List<Conversation>> getConversations() async {
    try {
      final response = await dio.get('/conversation/all');

      if (response.statusCode == 200 && response.data is List) {
        final List<dynamic> list = response.data as List<dynamic>;
        return list
            .map((json) => Conversation.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      throw AuthenticationException(
        'Failed to load conversations (${response.statusCode})',
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      final message = _extractErrorMessage(e, fallback: 'Failed to load conversations');
      throw AuthenticationException(message, e.response?.statusCode ?? 0);
    }
  }

  String _extractErrorMessage(DioException e, {required String fallback}) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return 'Cannot connect to server. Please check your connection.';
    }
    if (e.response?.data is Map && (e.response?.data as Map)['message'] != null) {
      return (e.response?.data as Map)['message'].toString();
    }
    return fallback;
  }
}

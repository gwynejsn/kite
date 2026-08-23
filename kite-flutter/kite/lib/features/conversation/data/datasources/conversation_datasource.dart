import 'package:dio/dio.dart';
import 'package:kite/features/conversation/domain/conversation.dart';
import 'package:kite/features/conversation/domain/encrypted_payload.dart';
import 'package:kite/features/conversation/domain/message_response.dart';
import 'package:kite/features/conversation/domain/message_type.dart';
import 'package:kite/shared/exceptions/authentication_exception.dart';

/// sending message is http, but getting realtime update is via websockets
class ConversationDatasource {
  final Dio dio;

  ConversationDatasource(this.dio);

  Future<List<Conversation>> getConversations() => getInitialConversations();

  Future<List<Conversation>> getInitialConversations() async {
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
      final message = _extractErrorMessage(
        e,
        fallback: 'Failed to load conversations',
      );
      throw AuthenticationException(message, e.response?.statusCode ?? 0);
    }
  }

  Future<List<MessageResponse>> getInitialMessages(
    String conversationId,
  ) async {
    try {
      final response = await dio.get('/conversation/$conversationId');

      if (response.statusCode == 200 && response.data is List) {
        final List<dynamic> list = response.data as List<dynamic>;
        return list
            .map(
              (json) => MessageResponse.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      }
      throw AuthenticationException(
        'Failed to load messages (${response.statusCode})',
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      final message = _extractErrorMessage(
        e,
        fallback: 'Failed to load messages',
      );
      throw AuthenticationException(message, e.response?.statusCode ?? 0);
    }
  }

  Future<MessageResponse> sendMessage({
    required String conversationId,
    required EncryptedPayload encryptedPayload,
    MessageType messageType = MessageType.text,
    String? mediaUrl,
    String? replyToMessageId,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'conversationId': conversationId,
        'encryptedPayload': encryptedPayload.toJson(),
        'messageType': messageType.name.toUpperCase(),
      };
      if (mediaUrl != null) body['mediaUrl'] = mediaUrl;
      if (replyToMessageId != null) body['replyToMessageId'] = replyToMessageId;

      final response = await dio.post('/conversation/message', data: body);

      if (response.statusCode == 200 && response.data is Map) {
        return MessageResponse.fromJson(response.data as Map<String, dynamic>);
      }
      throw AuthenticationException(
        'Failed to send message',
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      final message = _extractErrorMessage(
        e,
        fallback: 'Failed to send message',
      );
      throw AuthenticationException(message, e.response?.statusCode ?? 0);
    }
  }

  Future<Conversation> createGroupConversation({
    required String conversationName,
    required List<String> memberIds,
    String? conversationPhoto,
    List<String>? adminIds,
    Map<String, String>? groupKeyMap,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'conversationName': conversationName,
        'membersId': memberIds,
      };
      if (conversationPhoto != null && conversationPhoto.isNotEmpty) {
        body['conversationPhoto'] = conversationPhoto;
      }
      if (adminIds != null) {
        body['adminsId'] = adminIds;
      }
      if (groupKeyMap != null && groupKeyMap.isNotEmpty) {
        body['groupKeyMap'] = groupKeyMap;
      }

      final response = await dio.post('/conversation/group/create', data: body);

      if (response.statusCode == 200 && response.data is Map) {
        return Conversation.fromJson(response.data as Map<String, dynamic>);
      }
      throw AuthenticationException(
        'Failed to create group conversation',
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      final message = _extractErrorMessage(
        e,
        fallback: 'Failed to create group conversation',
      );
      throw AuthenticationException(message, e.response?.statusCode ?? 0);
    }
  }

  Future<Conversation> addMembers({
    required String conversationId,
    required List<String> memberIds,
    Map<String, String>? groupKeyMap,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'memberIds': memberIds,
      };
      if (groupKeyMap != null && groupKeyMap.isNotEmpty) {
        body['groupKeyMap'] = groupKeyMap;
      }

      final response = await dio.post(
        '/conversation/$conversationId/members/add',
        data: body,
      );

      if (response.statusCode == 200 && response.data is Map) {
        return Conversation.fromJson(response.data as Map<String, dynamic>);
      }
      throw AuthenticationException(
        'Failed to add members',
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      final message = _extractErrorMessage(
        e,
        fallback: 'Failed to add members',
      );
      throw AuthenticationException(message, e.response?.statusCode ?? 0);
    }
  }

  Future<Conversation> kickMember({
    required String conversationId,
    required String targetMemberId,
  }) async {
    try {
      final response = await dio.post(
        '/conversation/$conversationId/members/kick/$targetMemberId',
      );

      if (response.statusCode == 200 && response.data is Map) {
        return Conversation.fromJson(response.data as Map<String, dynamic>);
      }
      throw AuthenticationException(
        'Failed to kick member',
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      final message = _extractErrorMessage(
        e,
        fallback: 'Failed to kick member',
      );
      throw AuthenticationException(message, e.response?.statusCode ?? 0);
    }
  }

  Future<Conversation> promoteMember({
    required String conversationId,
    required String targetMemberId,
  }) async {
    try {
      final response = await dio.post(
        '/conversation/$conversationId/members/promote/$targetMemberId',
      );

      if (response.statusCode == 200 && response.data is Map) {
        return Conversation.fromJson(response.data as Map<String, dynamic>);
      }
      throw AuthenticationException(
        'Failed to promote member',
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      final message = _extractErrorMessage(
        e,
        fallback: 'Failed to promote member',
      );
      throw AuthenticationException(message, e.response?.statusCode ?? 0);
    }
  }

  Future<Conversation> demoteMember({
    required String conversationId,
    required String targetMemberId,
  }) async {
    try {
      final response = await dio.post(
        '/conversation/$conversationId/members/demote/$targetMemberId',
      );

      if (response.statusCode == 200 && response.data is Map) {
        return Conversation.fromJson(response.data as Map<String, dynamic>);
      }
      throw AuthenticationException(
        'Failed to demote member',
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      final message = _extractErrorMessage(
        e,
        fallback: 'Failed to demote member',
      );
      throw AuthenticationException(message, e.response?.statusCode ?? 0);
    }
  }

  Future<void> leaveGroup({
    required String conversationId,
  }) async {
    try {
      final response = await dio.post('/conversation/$conversationId/leave');

      if (response.statusCode == 200) {
        return;
      }
      throw AuthenticationException(
        'Failed to leave group',
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      final message = _extractErrorMessage(
        e,
        fallback: 'Failed to leave group',
      );
      throw AuthenticationException(message, e.response?.statusCode ?? 0);
    }
  }

  String _extractErrorMessage(DioException e, {required String fallback}) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return 'Cannot connect to server. Please check your connection.';
    }
    if (e.response?.data is Map &&
        (e.response?.data as Map)['message'] != null) {
      return (e.response?.data as Map)['message'].toString();
    }
    return fallback;
  }
}

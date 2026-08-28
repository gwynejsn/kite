import 'package:dio/dio.dart';
import 'package:kite/features/social/domain/user_discovery.dart';
import 'package:kite/shared/exceptions/authentication_exception.dart';

class SocialDatasource {
  final Dio dio;

  SocialDatasource(this.dio);

  Future<List<UserDiscovery>> getPeopleToConnect() async {
    try {
      final response = await dio.get('/social/people');

      if (response.statusCode == 200 && response.data is List) {
        final List<dynamic> list = response.data as List<dynamic>;
        return list
            .map((json) => UserDiscovery.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      throw AuthenticationException(
        'Failed to load people (${response.statusCode})',
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      final message = _extractErrorMessage(e, fallback: 'Failed to load people');
      throw AuthenticationException(message, e.response?.statusCode ?? 0);
    }
  }

  Future<void> sendFriendRequest(String targetUserId) async {
    try {
      await dio.post('/social/request/$targetUserId');
    } on DioException catch (e) {
      final message = _extractErrorMessage(e, fallback: 'Failed to send friend request');
      throw AuthenticationException(message, e.response?.statusCode ?? 0);
    }
  }

  Future<void> acceptFriendRequest(String relationId) async {
    try {
      await dio.put('/social/accept/$relationId');
    } on DioException catch (e) {
      final message = _extractErrorMessage(e, fallback: 'Failed to accept friend request');
      throw AuthenticationException(message, e.response?.statusCode ?? 0);
    }
  }

  Future<void> declineFriendRequest(String relationId) async {
    try {
      await dio.put('/social/decline/$relationId');
    } on DioException catch (e) {
      final message = _extractErrorMessage(e, fallback: 'Failed to decline friend request');
      throw AuthenticationException(message, e.response?.statusCode ?? 0);
    }
  }

  Future<void> blockUser(String targetUserId) async {
    try {
      await dio.post('/social/block/$targetUserId');
    } on DioException catch (e) {
      final message = _extractErrorMessage(e, fallback: 'Failed to block user');
      throw AuthenticationException(message, e.response?.statusCode ?? 0);
    }
  }

  Future<void> unblockUser(String targetUserId) async {
    try {
      await dio.post('/social/unblock/$targetUserId');
    } on DioException catch (e) {
      final message = _extractErrorMessage(e, fallback: 'Failed to unblock user');
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

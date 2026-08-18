import 'package:dio/dio.dart';
import 'package:kite/features/presence/domain/user_presence.dart';

class PresenceDatasource {
  final Dio dio;

  PresenceDatasource(this.dio);

  Future<Map<String, UserPresence>> getBatchPresence(
    Set<String> userIds,
  ) async {
    if (userIds.isEmpty) return {};
    try {
      final response = await dio.post(
        '/presence/batch',
        data: userIds.toList(),
      );

      if (response.statusCode == 200 && response.data is Map) {
        final Map<String, dynamic> data = response.data as Map<String, dynamic>;
        final Map<String, UserPresence> map = {};
        data.forEach((key, val) {
          if (val is Map<String, dynamic>) {
            map[key] = UserPresence.fromJson(val);
          }
        });
        return map;
      }
    } catch (_) {}
    return {};
  }
}

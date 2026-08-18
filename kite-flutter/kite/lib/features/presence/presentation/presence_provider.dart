import 'package:flutter/foundation.dart';
import 'package:kite/features/presence/data/presence_datasource.dart';
import 'package:kite/features/presence/domain/user_presence.dart';
import 'package:kite/shared/networks/websocket_service.dart';

class PresenceProvider extends ChangeNotifier {
  final PresenceDatasource _datasource;
  final WebsocketService _websocketService;

  final Map<String, UserPresence> _presenceMap = {};
  final Map<String, void Function({Map<String, String>? unsubscribeHeaders})?>
  _subscriptions = {};

  PresenceProvider(this._datasource, this._websocketService);

  Map<String, UserPresence> get presenceMap => Map.unmodifiable(_presenceMap);

  bool isUserOnline(String userId) {
    return _presenceMap[userId]?.isOnline ?? false;
  }

  bool isAnyMemberOnline(Set<String> memberIds, String? currentUserId) {
    return memberIds.any((id) => id != currentUserId && isUserOnline(id));
  }

  UserPresence? getPresence(String userId) => _presenceMap[userId];

  /// function to initialize and subscribe to the user presence map via websocket
  Future<void> fetchAndTrackPresences(Set<String> userIds) async {
    if (userIds.isEmpty) return;

    final batchResult = await _datasource.getBatchPresence(userIds);
    _presenceMap.addAll(batchResult);
    notifyListeners();

    for (final uId in userIds) {
      if (uId.isNotEmpty && !_subscriptions.containsKey(uId)) {
        _subscribeToUserPresence(uId);
      }
    }
  }

  void _subscribeToUserPresence(String targetUserId) {
    if (targetUserId.isEmpty) return;
    _websocketService.connect(
      onConnectCallback: () {
        final unsub = _websocketService.subscribeToUserPresence(
          userId: targetUserId,
          onPresenceUpdated: (jsonMap) {
            final updatedPresence = UserPresence.fromJson(jsonMap);
            _presenceMap[targetUserId] = updatedPresence;
            notifyListeners();
          },
        );
        _subscriptions[targetUserId] = unsub;
      },
    );
  }

  @override
  void dispose() {
    for (final unsub in _subscriptions.values) {
      unsub?.call();
    }
    _subscriptions.clear();
    super.dispose();
  }
}

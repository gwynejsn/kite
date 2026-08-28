import 'package:kite/features/social/domain/user_discovery.dart';

abstract interface class SocialRepository {
  Future<List<UserDiscovery>> getPeopleToConnect();
  Future<void> sendFriendRequest(String targetUserId);
  Future<void> acceptFriendRequest(String relationId);
  Future<void> declineFriendRequest(String relationId);
  Future<void> blockUser(String targetUserId);
  Future<void> unblockUser(String targetUserId);
}

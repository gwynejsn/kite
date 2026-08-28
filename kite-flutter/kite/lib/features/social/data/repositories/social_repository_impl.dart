import 'package:kite/features/social/data/datasources/social_datasource.dart';
import 'package:kite/features/social/domain/repositories/social_repository.dart';
import 'package:kite/features/social/domain/user_discovery.dart';

class SocialRepositoryImpl implements SocialRepository {
  final SocialDatasource datasource;

  SocialRepositoryImpl(this.datasource);

  @override
  Future<List<UserDiscovery>> getPeopleToConnect() {
    return datasource.getPeopleToConnect();
  }

  @override
  Future<void> sendFriendRequest(String targetUserId) {
    return datasource.sendFriendRequest(targetUserId);
  }

  @override
  Future<void> acceptFriendRequest(String relationId) {
    return datasource.acceptFriendRequest(relationId);
  }

  @override
  Future<void> declineFriendRequest(String relationId) {
    return datasource.declineFriendRequest(relationId);
  }

  @override
  Future<void> blockUser(String targetUserId) {
    return datasource.blockUser(targetUserId);
  }

  @override
  Future<void> unblockUser(String targetUserId) {
    return datasource.unblockUser(targetUserId);
  }
}

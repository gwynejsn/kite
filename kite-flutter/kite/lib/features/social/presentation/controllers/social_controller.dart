import 'package:flutter/foundation.dart';
import 'package:kite/features/social/domain/repositories/social_repository.dart';
import 'package:kite/features/social/presentation/controllers/social_state.dart';
import 'package:kite/shared/exceptions/authentication_exception.dart';

class SocialController extends ValueNotifier<SocialState> {
  final SocialRepository _repository;

  SocialController(this._repository) : super(const SocialState());

  Future<void> fetchPeople() async {
    value = value.copyWith(isLoading: true, errorMessage: null);

    try {
      final people = await _repository.getPeopleToConnect();
      value = value.copyWith(
        isLoading: false,
        people: people,
      );
    } on AuthenticationException catch (e) {
      value = value.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
    } catch (e) {
      value = value.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> sendFriendRequest(String targetUserId) async {
    try {
      await _repository.sendFriendRequest(targetUserId);
      await fetchPeople();
    } catch (e) {
      value = value.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> acceptFriendRequest(String relationId) async {
    try {
      await _repository.acceptFriendRequest(relationId);
      await fetchPeople();
    } catch (e) {
      value = value.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> declineFriendRequest(String relationId) async {
    try {
      await _repository.declineFriendRequest(relationId);
      await fetchPeople();
    } catch (e) {
      value = value.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> blockUser(String targetUserId) async {
    try {
      await _repository.blockUser(targetUserId);
      await fetchPeople();
    } catch (e) {
      value = value.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> unblockUser(String targetUserId) async {
    try {
      await _repository.unblockUser(targetUserId);
      await fetchPeople();
    } catch (e) {
      value = value.copyWith(errorMessage: e.toString());
    }
  }
}

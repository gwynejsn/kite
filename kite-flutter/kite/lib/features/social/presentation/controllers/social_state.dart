import 'package:kite/features/social/domain/user_discovery.dart';

class SocialState {
  final bool isLoading;
  final String? errorMessage;
  final List<UserDiscovery> people;

  const SocialState({
    this.isLoading = false,
    this.errorMessage,
    this.people = const [],
  });

  SocialState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<UserDiscovery>? people,
  }) {
    return SocialState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      people: people ?? this.people,
    );
  }
}

import 'package:kite/features/conversation/domain/conversation.dart';

class ConversationState {
  final bool isLoading;
  final String? errorMessage;
  final List<Conversation> conversations;

  const ConversationState({
    this.isLoading = false,
    this.errorMessage,
    this.conversations = const [],
  });

  ConversationState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<Conversation>? conversations,
  }) {
    return ConversationState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      conversations: conversations ?? this.conversations,
    );
  }
}

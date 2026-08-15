import 'package:kite/features/conversation/domain/message_response.dart';

class ConversationRoomState {
  final bool isLoading;
  final String? errorMessage;
  final List<MessageResponse> messages;

  const ConversationRoomState({
    this.isLoading = false,
    this.errorMessage,
    this.messages = const [],
  });

  ConversationRoomState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<MessageResponse>? messages,
  }) {
    return ConversationRoomState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      messages: messages ?? this.messages,
    );
  }
}

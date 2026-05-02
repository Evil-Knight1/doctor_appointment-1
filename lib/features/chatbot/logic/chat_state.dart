part of 'chat_cubit.dart';

enum ChatStatus { initial, loading, ready, sending, error }

class ChatState extends Equatable {
  final ChatStatus status;
  final List<AIChatMessage> messages;
  final String? errorMessage;
  final String? pendingUserMessage;

  const ChatState({
    this.status = ChatStatus.initial,
    this.messages = const [],
    this.errorMessage,
    this.pendingUserMessage,
  });

  ChatState copyWith({
    ChatStatus? status,
    List<AIChatMessage>? messages,
    String? errorMessage,
    String? pendingUserMessage,
    bool clearPendingUserMessage = false,
  }) {
    return ChatState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      errorMessage: errorMessage ?? this.errorMessage,
      pendingUserMessage: clearPendingUserMessage ? null : (pendingUserMessage ?? this.pendingUserMessage),
    );
  }

  @override
  List<Object?> get props => [status, messages, errorMessage, pendingUserMessage];
}

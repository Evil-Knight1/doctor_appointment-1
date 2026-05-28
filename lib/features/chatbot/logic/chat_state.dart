part of 'chat_cubit.dart';

enum ChatStatus { initial, loading, ready, sending, error, limitReached }

class ChatState extends Equatable {
  final ChatStatus status;
  final List<AIChatMessage> messages;
  final String? errorMessage;
  final String? pendingUserMessage;
  final UiComponent? currentUi;
  final Map<String, dynamic>? currentStructuredReport;
  final String? currentRiskLevel;

  const ChatState({
    this.status = ChatStatus.initial,
    this.messages = const [],
    this.errorMessage,
    this.pendingUserMessage,
    this.currentUi,
    this.currentStructuredReport,
    this.currentRiskLevel,
  });

  ChatState copyWith({
    ChatStatus? status,
    List<AIChatMessage>? messages,
    String? errorMessage,
    String? pendingUserMessage,
    bool clearPendingUserMessage = false,
    UiComponent? currentUi,
    Map<String, dynamic>? currentStructuredReport,
    String? currentRiskLevel,
  }) {
    return ChatState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      errorMessage: errorMessage ?? this.errorMessage,
      pendingUserMessage: clearPendingUserMessage ? null : (pendingUserMessage ?? this.pendingUserMessage),
      currentUi: currentUi ?? this.currentUi,
      currentStructuredReport: currentStructuredReport ?? this.currentStructuredReport,
      currentRiskLevel: currentRiskLevel ?? this.currentRiskLevel,
    );
  }

  @override
  List<Object?> get props => [
        status,
        messages,
        errorMessage,
        pendingUserMessage,
        currentUi,
        currentStructuredReport,
        currentRiskLevel,
      ];
}

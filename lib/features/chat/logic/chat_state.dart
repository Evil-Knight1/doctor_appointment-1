import 'package:equatable/equatable.dart';
import 'package:doctor_appointment/features/chat/data/models/chat_message_model.dart';

enum ChatStatus { initial, loading, success, sending, error }

class ChatState extends Equatable {
  final ChatStatus status;
  final List<ChatMessageModel> messages;
  final int? activeChatUserId;
  final String? errorMessage;
  final bool isConnected;

  const ChatState({
    this.status = ChatStatus.initial,
    this.messages = const [],
    this.activeChatUserId,
    this.errorMessage,
    this.isConnected = false,
  });

  ChatState copyWith({
    ChatStatus? status,
    List<ChatMessageModel>? messages,
    int? activeChatUserId,
    String? errorMessage,
    bool? isConnected,
  }) {
    return ChatState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      activeChatUserId: activeChatUserId ?? this.activeChatUserId,
      errorMessage: errorMessage ?? this.errorMessage,
      isConnected: isConnected ?? this.isConnected,
    );
  }

  @override
  List<Object?> get props => [status, messages, activeChatUserId, errorMessage, isConnected];
}

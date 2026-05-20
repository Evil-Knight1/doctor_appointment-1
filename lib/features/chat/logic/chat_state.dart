import 'package:equatable/equatable.dart';
import 'package:doctor_appointment/features/chat/data/models/chat_message_model.dart';

enum ChatStatus { initial, loading, success, sending, error }

class ChatState extends Equatable {
  static const Object _unset = Object();

  final ChatStatus status;
  final List<ChatMessageModel> messages;
  final int? activeChatUserId;
  final String? errorMessage;
  final bool isConnected;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;

  const ChatState({
    this.status = ChatStatus.initial,
    this.messages = const [],
    this.activeChatUserId,
    this.errorMessage,
    this.isConnected = false,
    this.currentPage = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  ChatState copyWith({
    ChatStatus? status,
    List<ChatMessageModel>? messages,
    int? activeChatUserId,
    Object? errorMessage = _unset,
    bool? isConnected,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return ChatState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      activeChatUserId: activeChatUserId ?? this.activeChatUserId,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
      isConnected: isConnected ?? this.isConnected,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [
        status,
        messages,
        activeChatUserId,
        errorMessage,
        isConnected,
        currentPage,
        hasMore,
        isLoadingMore,
      ];
}

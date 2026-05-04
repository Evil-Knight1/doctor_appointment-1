import 'package:equatable/equatable.dart';
import 'package:doctor_appointment/features/chat/data/models/conversation_model.dart';

enum ConversationsStatus { initial, loading, success, error }

class ConversationsState extends Equatable {
  final ConversationsStatus status;
  final List<ConversationModel> conversations;
  final int totalUnreadCount;
  final String? errorMessage;

  const ConversationsState({
    this.status = ConversationsStatus.initial,
    this.conversations = const [],
    this.totalUnreadCount = 0,
    this.errorMessage,
  });

  ConversationsState copyWith({
    ConversationsStatus? status,
    List<ConversationModel>? conversations,
    int? totalUnreadCount,
    String? errorMessage,
  }) {
    return ConversationsState(
      status: status ?? this.status,
      conversations: conversations ?? this.conversations,
      totalUnreadCount: totalUnreadCount ?? this.totalUnreadCount,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, conversations, totalUnreadCount, errorMessage];
}

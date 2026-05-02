part of 'chat_history_cubit.dart';

abstract class ChatHistoryState extends Equatable {
  const ChatHistoryState();

  @override
  List<Object> get props => [];
}

class ChatHistoryInitial extends ChatHistoryState {}

class ChatHistoryLoading extends ChatHistoryState {}

class ChatHistoryLoaded extends ChatHistoryState {
  final List<String> sessionIds;

  const ChatHistoryLoaded(this.sessionIds);

  @override
  List<Object> get props => [sessionIds];
}

class ChatHistoryError extends ChatHistoryState {
  final String message;

  const ChatHistoryError(this.message);

  @override
  List<Object> get props => [message];
}

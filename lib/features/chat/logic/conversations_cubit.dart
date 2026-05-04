import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doctor_appointment/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:doctor_appointment/features/chat/data/services/chat_signalr_service.dart';
import 'package:doctor_appointment/features/chat/logic/conversations_state.dart';
import 'package:doctor_appointment/features/chat/data/models/chat_message_model.dart';

class ConversationsCubit extends Cubit<ConversationsState> {
  final ChatRemoteDataSource _remoteDataSource;
  final ChatSignalRService _signalRService;
  StreamSubscription? _messageSubscription;

  ConversationsCubit(this._remoteDataSource, this._signalRService) : super(const ConversationsState()) {
    _init();
  }



  void _init() {
    _messageSubscription = _signalRService.messageStream.listen(_onMessageReceived);
  }

  void _onMessageReceived(ChatMessageModel message) {
    // Refresh conversations list when a new message is received
    fetchConversations();
  }

  Future<void> fetchConversations() async {
    emit(state.copyWith(status: ConversationsStatus.loading));
    try {
      final conversations = await _remoteDataSource.getConversations();
      final unreadCount = await _remoteDataSource.getUnreadCount();
      emit(state.copyWith(
        status: ConversationsStatus.success,
        conversations: conversations,
        totalUnreadCount: unreadCount,
      ));
    } catch (e) {
      emit(state.copyWith(status: ConversationsStatus.error, errorMessage: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    return super.close();
  }
}

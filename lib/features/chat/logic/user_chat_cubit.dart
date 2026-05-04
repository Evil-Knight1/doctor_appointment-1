import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doctor_appointment/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:doctor_appointment/features/chat/data/services/chat_signalr_service.dart';
import 'package:doctor_appointment/features/chat/logic/chat_state.dart';
import 'package:doctor_appointment/features/chat/data/models/chat_message_model.dart';

class UserChatCubit extends Cubit<ChatState> {
  final ChatRemoteDataSource _remoteDataSource;
  final ChatSignalRService _signalRService;
  StreamSubscription? _messageSubscription;
  StreamSubscription? _errorSubscription;

  UserChatCubit(this._remoteDataSource, this._signalRService) : super(const ChatState()) {
    _init();
  }

  void _init() {
    _messageSubscription = _signalRService.messageStream.listen(_onMessageReceived);
    _errorSubscription = _signalRService.errorStream.listen((error) {
      emit(state.copyWith(status: ChatStatus.error, errorMessage: error));
    });
  }

  void _onMessageReceived(ChatMessageModel message) {
    if (state.activeChatUserId == message.senderId || 
        state.activeChatUserId == message.receiverId) {
      final updatedMessages = List<ChatMessageModel>.from(state.messages)..add(message);
      emit(state.copyWith(messages: updatedMessages));
      
      // Mark as read if we are the receiver
      if (state.activeChatUserId == message.senderId) {
        markAsRead(message.senderId);
      }
    }
  }

  Future<void> fetchChatHistory(int otherUserId) async {
    emit(state.copyWith(status: ChatStatus.loading, activeChatUserId: otherUserId));
    try {
      final messages = await _remoteDataSource.getChatHistory(otherUserId);
      emit(state.copyWith(status: ChatStatus.success, messages: messages));
      await markAsRead(otherUserId);
    } catch (e) {
      emit(state.copyWith(status: ChatStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> sendMessage(String text) async {
    if (state.activeChatUserId == null) return;
    try {
      await _signalRService.sendMessage(state.activeChatUserId!, text);
    } catch (e) {
      emit(state.copyWith(status: ChatStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> markAsRead(int otherUserId) async {
    try {
      await _remoteDataSource.markAsRead(otherUserId);
    } catch (e) {
      // Log error but don't break UI for markAsRead failure
      print('Error marking as read: $e');
    }
  }

  Future<void> connect() async {
    try {
      await _signalRService.connect();
      emit(state.copyWith(isConnected: true));
    } catch (e) {
      emit(state.copyWith(isConnected: false, errorMessage: e.toString()));
    }
  }

  Future<void> disconnect() async {
    await _signalRService.disconnect();
    emit(state.copyWith(isConnected: false));
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    _errorSubscription?.cancel();
    return super.close();
  }
}

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doctor_appointment/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:doctor_appointment/features/chat/data/services/chat_signalr_service.dart';
import 'package:doctor_appointment/features/chat/logic/chat_state.dart';
import 'package:doctor_appointment/features/chat/data/models/chat_message_model.dart';
import 'package:doctor_appointment/core/logging/log_service.dart';
import 'package:doctor_appointment/core/services/service_locator.dart';

class UserChatCubit extends Cubit<ChatState> {
  final ChatRemoteDataSource _remoteDataSource;
  final ChatSignalRService _signalRService;
  StreamSubscription? _messageSubscription;
  StreamSubscription? _errorSubscription;
  StreamSubscription? _readSubscription;

  UserChatCubit(this._remoteDataSource, this._signalRService) : super(const ChatState()) {
    _init();
  }

  void _init() {
    _messageSubscription = _signalRService.messageStream.listen(_onMessageReceived);
    _readSubscription = _signalRService.readStream.listen(_onMessagesReadReceived);
    _errorSubscription = _signalRService.errorStream.listen((error) {
      emit(state.copyWith(status: ChatStatus.error, errorMessage: error));
    });
  }

  void _onMessagesReadReceived(int readerId) {
    if (state.activeChatUserId == readerId) {
      final updatedMessages = state.messages.map((message) {
        if (message.receiverId == readerId && !message.isRead) {
          return message.copyWith(isRead: true);
        }
        return message;
      }).toList();
      emit(state.copyWith(messages: updatedMessages));
    }
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
    await sendMessageViaApi(state.activeChatUserId!, text);
  }

  Future<void> sendMessageViaApi(int receiverId, String text) async {
    emit(state.copyWith(status: ChatStatus.loading));
    try {
      final message = await _remoteDataSource.sendMessage(receiverId, text);
      final updatedMessage = message.copyWith(isRead: false);
      final updatedMessages = List<ChatMessageModel>.from(state.messages)..add(updatedMessage);
      emit(state.copyWith(status: ChatStatus.success, messages: updatedMessages));
    } catch (e) {
      emit(state.copyWith(status: ChatStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> markAsRead(int otherUserId) async {
    try {
      await _remoteDataSource.markAsRead(otherUserId);
    } catch (e) {
      // Log error but don't break UI for markAsRead failure
      getIt<LogService>().w('Error marking as read: $e');
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
    _readSubscription?.cancel();
    return super.close();
  }
}

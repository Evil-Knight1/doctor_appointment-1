import 'dart:async';
import 'dart:convert';

import 'package:doctor_appointment/core/logging/log_service.dart';
import 'package:doctor_appointment/core/services/chat_cache_service.dart';
import 'package:doctor_appointment/core/services/service_locator.dart';
import 'package:doctor_appointment/core/services/shared_preferences_helper.dart';
import 'package:doctor_appointment/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:doctor_appointment/features/chat/data/models/chat_message_model.dart';
import 'package:doctor_appointment/features/chat/data/services/chat_signalr_service.dart';
import 'package:doctor_appointment/features/chat/logic/chat_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:signalr_core/signalr_core.dart';

class UserChatCubit extends Cubit<ChatState> {
  static const Duration _historyRefreshInterval = Duration(seconds: 4);

  final ChatRemoteDataSource _remoteDataSource;
  final ChatSignalRService _signalRService;
  final ChatCacheService _cacheService;

  StreamSubscription? _messageSubscription;
  StreamSubscription? _errorSubscription;
  StreamSubscription? _readSubscription;
  StreamSubscription? _connectionSubscription;
  Timer? _historyRefreshTimer;

  UserChatCubit(
    this._remoteDataSource,
    this._signalRService,
    this._cacheService,
  ) : super(const ChatState()) {
    _init();
  }

  void _init() {
    _messageSubscription =
        _signalRService.messageStream.listen(_onMessageReceived);
    _readSubscription =
        _signalRService.readStream.listen(_onMessagesReadReceived);
    _connectionSubscription = _signalRService.connectionStream.listen((
      isConnected,
    ) {
      emit(state.copyWith(isConnected: isConnected));
      if (isConnected && state.activeChatUserId != null) {
        unawaited(_refreshActiveChatSilently());
      }
    });
    _errorSubscription = _signalRService.errorStream.listen((error) {
      emit(state.copyWith(
        status: ChatStatus.error,
        errorMessage: error,
        isConnected: _signalRService.state == HubConnectionState.connected,
      ));
    });
  }

  void _onMessagesReadReceived(int readerId) {
    if (state.activeChatUserId != readerId) return;

    final updatedMessages = state.messages.map((message) {
      if (message.receiverId == readerId && !message.isRead) {
        return message.copyWith(isRead: true);
      }
      return message;
    }).toList();

    emit(state.copyWith(messages: updatedMessages));

    if (state.activeChatUserId != null) {
      unawaited(
        _cacheService.cacheMessages(state.activeChatUserId!, updatedMessages),
      );
    }
  }

  void _onMessageReceived(ChatMessageModel message) {
    if (state.activeChatUserId != message.senderId &&
        state.activeChatUserId != message.receiverId) {
      return;
    }

    final updatedMessages = _mergeMessages(state.messages, [message]);
    emit(state.copyWith(
      status: ChatStatus.success,
      messages: updatedMessages,
      errorMessage: null,
    ));

    if (state.activeChatUserId != null) {
      unawaited(
        _cacheService.cacheMessages(state.activeChatUserId!, updatedMessages),
      );
    }

    if (state.activeChatUserId == message.senderId) {
      unawaited(markAsRead(message.senderId));
    }
  }

  Future<void> fetchChatHistory(int otherUserId) async {
    final cached = _cacheService.getCachedMessages(otherUserId);
    emit(state.copyWith(
      activeChatUserId: otherUserId,
      messages: cached,
      status: cached.isNotEmpty ? ChatStatus.success : ChatStatus.loading,
      errorMessage: null,
    ));

    _startHistoryRefreshTimer();

    try {
      final messages = await _remoteDataSource.getChatHistory(otherUserId);
      final mergedMessages = _mergeMessages(state.messages, messages);

      await _cacheService.cacheMessages(otherUserId, mergedMessages);
      emit(state.copyWith(
        status: ChatStatus.success,
        messages: mergedMessages,
        errorMessage: null,
      ));
      await markAsRead(otherUserId);
    } catch (e) {
      if (state.messages.isEmpty) {
        emit(state.copyWith(
          status: ChatStatus.error,
          errorMessage: e.toString(),
        ));
      }
    }
  }

  Future<void> sendMessage(String text) async {
    if (state.activeChatUserId == null) return;
    await sendMessageViaApi(state.activeChatUserId!, text);
  }

  Future<void> sendMessageViaApi(int receiverId, String text) async {
    final currentUserId = _getCurrentUserId();
    final tempId = -DateTime.now().millisecondsSinceEpoch;
    final tempMessage = ChatMessageModel(
      id: tempId,
      senderId: currentUserId,
      senderName: '',
      receiverId: receiverId,
      receiverName: '',
      message: text,
      timestamp: DateTime.now(),
      isRead: false,
    );

    final optimisticMessages = List<ChatMessageModel>.from(state.messages)
      ..add(tempMessage);
    emit(state.copyWith(
      status: ChatStatus.success,
      messages: optimisticMessages,
      errorMessage: null,
    ));

    try {
      final message = await _remoteDataSource.sendMessage(receiverId, text);
      final realMessage = message.copyWith(isRead: false);
      final withoutTemp = optimisticMessages
          .where((existingMessage) => existingMessage.id != tempId)
          .toList();
      final realMessages = _mergeMessages(withoutTemp, [realMessage]);

      await _cacheService.cacheMessages(receiverId, realMessages);
      emit(state.copyWith(
        status: ChatStatus.success,
        messages: realMessages,
        errorMessage: null,
      ));
    } catch (e) {
      final revertedMessages = List<ChatMessageModel>.from(state.messages)
        ..removeWhere((message) => message.id == tempId);
      emit(state.copyWith(
        status: ChatStatus.error,
        errorMessage: e.toString(),
        messages: revertedMessages,
      ));
    }
  }

  Future<void> markAsRead(int otherUserId) async {
    try {
      await _remoteDataSource.markAsRead(otherUserId);
    } catch (e) {
      getIt<LogService>().w('Error marking as read: $e');
    }
  }

  Future<void> connect() async {
    final isConnected = await _signalRService.connect();
    emit(state.copyWith(
      isConnected: isConnected,
      errorMessage: isConnected ? null : state.errorMessage,
    ));
  }

  Future<void> disconnect() async {
    _historyRefreshTimer?.cancel();
    await _signalRService.disconnect();
    emit(state.copyWith(isConnected: false));
  }

  void _startHistoryRefreshTimer() {
    _historyRefreshTimer?.cancel();
    _historyRefreshTimer = Timer.periodic(_historyRefreshInterval, (_) {
      unawaited(_refreshActiveChatSilently());
    });
  }

  Future<void> _refreshActiveChatSilently() async {
    final activeChatUserId = state.activeChatUserId;
    if (activeChatUserId == null) return;

    try {
      final latestMessages = await _remoteDataSource.getChatHistory(
        activeChatUserId,
      );
      final mergedMessages = _mergeMessages(state.messages, latestMessages);
      if (_sameMessageSet(state.messages, mergedMessages)) return;

      await _cacheService.cacheMessages(activeChatUserId, mergedMessages);
      emit(state.copyWith(
        status: ChatStatus.success,
        messages: mergedMessages,
        errorMessage: null,
      ));
      await markAsRead(activeChatUserId);
    } catch (e) {
      getIt<LogService>().w('Silent chat refresh failed: $e');
    }
  }

  List<ChatMessageModel> _mergeMessages(
    List<ChatMessageModel> currentMessages,
    List<ChatMessageModel> incomingMessages,
  ) {
    final messagesById = <int, ChatMessageModel>{};

    for (final message in [...currentMessages, ...incomingMessages]) {
      final existingMessage = messagesById[message.id];
      if (existingMessage == null ||
          _shouldReplaceMessage(existingMessage, message)) {
        messagesById[message.id] = message;
      }
    }

    final mergedMessages = messagesById.values.toList()
      ..sort((first, second) {
        final timeCompare = first.timestamp.compareTo(second.timestamp);
        return timeCompare != 0
            ? timeCompare
            : first.id.compareTo(second.id);
      });
    return mergedMessages;
  }

  bool _shouldReplaceMessage(
    ChatMessageModel existing,
    ChatMessageModel candidate,
  ) {
    if (existing.id < 0 && candidate.id > 0) {
      return true;
    }
    if (!existing.isRead && candidate.isRead) {
      return true;
    }
    return candidate.timestamp.isAfter(existing.timestamp);
  }

  bool _sameMessageSet(
    List<ChatMessageModel> currentMessages,
    List<ChatMessageModel> nextMessages,
  ) {
    if (currentMessages.length != nextMessages.length) return false;

    for (var index = 0; index < currentMessages.length; index++) {
      final current = currentMessages[index];
      final next = nextMessages[index];
      if (current.id != next.id ||
          current.isRead != next.isRead ||
          current.message != next.message ||
          current.timestamp != next.timestamp) {
        return false;
      }
    }

    return true;
  }

  int _getCurrentUserId() {
    try {
      final raw = SharedPreferencesHelper.getUserData();
      if (raw == null) return 0;
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return (decoded['id'] as int?) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  @override
  Future<void> close() {
    _historyRefreshTimer?.cancel();
    _messageSubscription?.cancel();
    _errorSubscription?.cancel();
    _readSubscription?.cancel();
    _connectionSubscription?.cancel();
    return super.close();
  }
}

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doctor_appointment/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:doctor_appointment/features/chat/data/services/chat_signalr_service.dart';
import 'package:doctor_appointment/features/chat/logic/conversations_state.dart';
import 'package:doctor_appointment/features/chat/data/models/chat_message_model.dart';
import 'package:doctor_appointment/core/services/chat_cache_service.dart';

class ConversationsCubit extends Cubit<ConversationsState> {
  final ChatRemoteDataSource _remoteDataSource;
  final ChatSignalRService _signalRService;
  final ChatCacheService _cacheService;
  StreamSubscription? _messageSubscription;

  ConversationsCubit(
    this._remoteDataSource,
    this._signalRService,
    this._cacheService,
  ) : super(const ConversationsState()) {
    _init();
  }

  void _init() {
    _messageSubscription =
        _signalRService.messageStream.listen(_onMessageReceived);
    _connect();
  }

  Future<void> _connect() async {
    try {
      await _signalRService.connect();
    } catch (_) {}
  }

  void _onMessageReceived(ChatMessageModel message) {
    // When a real-time message arrives, trigger a silent background refresh.
    // The cache will be updated and the UI will reflect the new conversation
    // without any loading indicator (stale-while-revalidate).
    fetchConversations();
  }

  /// Stale-While-Revalidate pattern:
  /// 1. Emit cached data immediately (instant display, 0 ms).
  /// 2. Fetch fresh data from API in background.
  /// 3. Update cache + emit new state silently.
  Future<void> fetchConversations() async {
    // ── Step 1: serve from cache ──────────────────────────────────────────
    final cached = _cacheService.getCachedConversations();
    if (cached.isNotEmpty) {
      emit(state.copyWith(
        status: ConversationsStatus.success,
        conversations: cached,
      ));
    } else {
      emit(state.copyWith(status: ConversationsStatus.loading));
    }

    // ── Step 2: background fetch ──────────────────────────────────────────
    try {
      final conversations = await _remoteDataSource.getConversations();
      final unreadCount = await _remoteDataSource.getUnreadCount();

      // ── Step 3: update cache + UI ────────────────────────────────────────
      await _cacheService.cacheConversations(conversations);
      emit(state.copyWith(
        status: ConversationsStatus.success,
        conversations: conversations,
        totalUnreadCount: unreadCount,
      ));
    } catch (e) {
      // Only show error when there is nothing to display.
      if (state.conversations.isEmpty) {
        emit(state.copyWith(
          status: ConversationsStatus.error,
          errorMessage: e.toString(),
        ));
      }
      // Otherwise silently fail — user keeps seeing cached data.
    }
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    return super.close();
  }
}

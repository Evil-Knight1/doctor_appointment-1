import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:doctor_appointment/features/chat/data/models/conversation_model.dart';
import 'package:doctor_appointment/features/chat/data/models/chat_message_model.dart';

/// Hive-backed cache for conversations list and per-user message history.
/// Uses JSON strings so no TypeAdapter code-gen is required.
class ChatCacheService {
  static const String conversationsBoxName = 'chat_conversations';
  static const String messagesBoxName = 'chat_messages';
  static const String _conversationsKey = 'conversations';

  final Box<String> _conversationsBox;
  final Box<String> _messagesBox;

  ChatCacheService(this._conversationsBox, this._messagesBox);

  /// Call once during app startup (after Hive.initFlutter).
  static Future<void> openBoxes() async {
    await Hive.openBox<String>(conversationsBoxName);
    await Hive.openBox<String>(messagesBoxName);
  }

  // ── Conversations ──────────────────────────────────────────────────────────

  /// Returns the cached conversations list synchronously (0 ms).
  List<ConversationModel> getCachedConversations() {
    final raw = _conversationsBox.get(_conversationsKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => ConversationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Persists the conversations list to Hive.
  Future<void> cacheConversations(List<ConversationModel> conversations) async {
    final jsonList = conversations.map((c) => c.toJson()).toList();
    await _conversationsBox.put(_conversationsKey, jsonEncode(jsonList));
  }

  // ── Messages ───────────────────────────────────────────────────────────────

  /// Returns cached messages for a specific chat partner synchronously (0 ms).
  List<ChatMessageModel> getCachedMessages(int otherUserId) {
    final raw = _messagesBox.get(otherUserId.toString());
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => ChatMessageModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Persists the full message list for [otherUserId].
  Future<void> cacheMessages(
      int otherUserId, List<ChatMessageModel> messages) async {
    final jsonList = messages.map((m) => m.toJson()).toList();
    await _messagesBox.put(otherUserId.toString(), jsonEncode(jsonList));
  }

  /// Appends a single message to the cached list (avoids full re-write for
  /// common append case, but falls back to full write if duplicate or error).
  Future<void> appendMessage(
      int otherUserId, ChatMessageModel message) async {
    final messages = getCachedMessages(otherUserId);
    if (messages.any((m) => m.id == message.id)) return; // already cached
    messages.add(message);
    await cacheMessages(otherUserId, messages);
  }

  /// Replaces a message in cache by [ChatMessageModel.id].
  Future<void> replaceMessage(
      int otherUserId, ChatMessageModel updated) async {
    final messages = getCachedMessages(otherUserId);
    final idx = messages.indexWhere((m) => m.id == updated.id);
    if (idx == -1) {
      messages.add(updated);
    } else {
      messages[idx] = updated;
    }
    await cacheMessages(otherUserId, messages);
  }

  /// Removes a message from cache by [id].
  Future<void> removeMessageById(int otherUserId, int messageId) async {
    final messages = getCachedMessages(otherUserId);
    messages.removeWhere((m) => m.id == messageId);
    await cacheMessages(otherUserId, messages);
  }

  /// Clears all chat caches (e.g. on logout).
  Future<void> clearAll() async {
    await _conversationsBox.clear();
    await _messagesBox.clear();
  }
}

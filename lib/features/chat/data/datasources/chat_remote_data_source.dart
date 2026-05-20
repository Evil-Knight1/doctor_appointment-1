import 'package:doctor_appointment/core/services/api_service.dart';
import 'package:doctor_appointment/features/chat/data/models/chat_message_model.dart';
import 'package:doctor_appointment/features/chat/data/models/conversation_model.dart';

abstract class ChatRemoteDataSource {
  Future<List<ChatMessageModel>> getChatHistory(int otherUserId, {int pageNumber = 1, int pageSize = 50});
  Future<List<ConversationModel>> getConversations();
  Future<bool> markAsRead(int otherUserId);
  Future<int> getUnreadCount();
  Future<ChatMessageModel> sendMessage(int receiverId, String message);
  Future<bool> reportMessage(int messageId, String reason);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final ApiService _apiService;

  ChatRemoteDataSourceImpl(this._apiService);

  @override
  Future<List<ChatMessageModel>> getChatHistory(int otherUserId, {int pageNumber = 1, int pageSize = 50}) async {
    final response = await _apiService.get(
      '/api/Chat/history/$otherUserId',
      queryParameters: {'pageNumber': pageNumber, 'pageSize': pageSize},
    );
    final List data = response['data'];
    return data.map((json) => ChatMessageModel.fromJson(json)).toList();
  }

  @override
  Future<List<ConversationModel>> getConversations() async {
    final response = await _apiService.get('/api/Chat/conversations');
    final List data = response['data'];
    return data.map((json) => ConversationModel.fromJson(json)).toList();
  }

  @override
  Future<bool> markAsRead(int otherUserId) async {
    final response = await _apiService.put('/api/Chat/read/$otherUserId');
    return response['data'] as bool;
  }

  @override
  Future<int> getUnreadCount() async {
    final response = await _apiService.get('/api/Chat/unread-count');
    return response['data'] as int;
  }

  @override
  Future<ChatMessageModel> sendMessage(int receiverId, String message) async {
    final response = await _apiService.post(
      '/api/Chat/send',
      data: {
        'receiverId': receiverId,
        'message': message,
      },
    );
    return ChatMessageModel.fromJson(response['data']);
  }

  @override
  Future<bool> reportMessage(int messageId, String reason) async {
    final response = await _apiService.post(
      '/api/Chat/report',
      data: {
        'reportedMessageId': messageId,
        'reason': reason,
      },
    );
    return response['data'] as bool;
  }
}

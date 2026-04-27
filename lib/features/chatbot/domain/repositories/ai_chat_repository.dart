import 'package:doctor_appointment/core/utils/result.dart';
import 'package:doctor_appointment/features/chatbot/domain/entities/ai_chat_entity.dart';

abstract class AIChatRepository {
  Future<Result<String>> startNewChat();
  Future<Result<List<String>>> getUserChats();
  Future<Result<AIChatResponse>> sendMessage(String sessionId, String message);
  Future<Result<List<AIChatMessage>>> getHistory(String sessionId);
}

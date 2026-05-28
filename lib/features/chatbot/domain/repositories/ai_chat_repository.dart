import 'package:doctor_appointment/core/utils/result.dart';
import 'package:doctor_appointment/features/chatbot/domain/entities/ai_chat_entity.dart';

abstract class AIChatRepository {
  Future<Result<NewChatResponse>> startNewChat();
  Future<Result<List<String>>> getUserChats();
  Future<Result<AIChatResponse>> sendMessage({
    required String sessionId,
    required String message,
    String? type,
    Map<String, dynamic>? metadata,
    Map<String, dynamic>? medicalContext,
    Map<String, dynamic>? toolResult,
  });
  Future<Result<List<AIChatMessage>>> getHistory(String sessionId);
}

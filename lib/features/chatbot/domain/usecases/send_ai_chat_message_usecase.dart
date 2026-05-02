import 'package:doctor_appointment/core/utils/result.dart';
import 'package:doctor_appointment/features/chatbot/domain/entities/ai_chat_entity.dart';
import 'package:doctor_appointment/features/chatbot/domain/repositories/ai_chat_repository.dart';

class SendAIChatMessageUseCase {
  final AIChatRepository repository;

  SendAIChatMessageUseCase(this.repository);

  Future<Result<AIChatResponse>> call(String sessionId, String message) {
    return repository.sendMessage(sessionId, message);
  }
}

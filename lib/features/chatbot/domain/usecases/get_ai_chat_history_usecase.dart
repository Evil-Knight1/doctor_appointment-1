import 'package:doctor_appointment/core/utils/result.dart';
import 'package:doctor_appointment/features/chatbot/domain/entities/ai_chat_entity.dart';
import 'package:doctor_appointment/features/chatbot/domain/repositories/ai_chat_repository.dart';

class GetAIChatHistoryUseCase {
  final AIChatRepository repository;

  GetAIChatHistoryUseCase(this.repository);

  Future<Result<List<AIChatMessage>>> call(String sessionId) {
    return repository.getHistory(sessionId);
  }
}

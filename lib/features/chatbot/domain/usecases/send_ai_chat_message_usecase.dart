import 'package:doctor_appointment/core/utils/result.dart';
import 'package:doctor_appointment/features/chatbot/domain/entities/ai_chat_entity.dart';
import 'package:doctor_appointment/features/chatbot/domain/repositories/ai_chat_repository.dart';

class SendAIChatMessageUseCase {
  final AIChatRepository repository;

  SendAIChatMessageUseCase(this.repository);

  Future<Result<AIChatResponse>> call({
    required String sessionId,
    required String message,
    String? type,
    Map<String, dynamic>? metadata,
    Map<String, dynamic>? medicalContext,
    Map<String, dynamic>? toolResult,
  }) {
    return repository.sendMessage(
      sessionId: sessionId,
      message: message,
      type: type,
      metadata: metadata,
      medicalContext: medicalContext,
      toolResult: toolResult,
    );
  }
}

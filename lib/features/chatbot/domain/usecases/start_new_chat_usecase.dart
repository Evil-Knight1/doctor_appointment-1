import 'package:doctor_appointment/core/utils/result.dart';
import 'package:doctor_appointment/features/chatbot/domain/repositories/ai_chat_repository.dart';

class StartNewChatUseCase {
  final AIChatRepository repository;

  StartNewChatUseCase(this.repository);

  Future<Result<String>> call() {
    return repository.startNewChat();
  }
}

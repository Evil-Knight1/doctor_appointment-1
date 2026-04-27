import 'package:doctor_appointment/core/utils/result.dart';
import 'package:doctor_appointment/features/chatbot/domain/repositories/ai_chat_repository.dart';

class GetUserChatsUseCase {
  final AIChatRepository repository;

  GetUserChatsUseCase(this.repository);

  Future<Result<List<String>>> call() {
    return repository.getUserChats();
  }
}

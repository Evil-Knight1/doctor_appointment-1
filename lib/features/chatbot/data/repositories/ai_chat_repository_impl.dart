import 'package:doctor_appointment/core/errors/failures.dart';
import 'package:doctor_appointment/core/utils/result.dart';
import 'package:doctor_appointment/features/chatbot/data/datasources/ai_chat_remote_data_source.dart';
import 'package:doctor_appointment/features/chatbot/data/models/ai_chat_models.dart';
import 'package:doctor_appointment/features/chatbot/domain/entities/ai_chat_entity.dart';
import 'package:doctor_appointment/features/chatbot/domain/repositories/ai_chat_repository.dart';

class AIChatRepositoryImpl implements AIChatRepository {
  final AIChatRemoteDataSource _remoteDataSource;

  AIChatRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<String>> startNewChat() async {
    try {
      final sessionId = await _remoteDataSource.startNewChat();
      return Result.success(sessionId);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<String>>> getUserChats() async {
    try {
      final chats = await _remoteDataSource.getUserChats();
      return Result.success(chats);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<AIChatResponse>> sendMessage(String sessionId, String message) async {
    try {
      final request = AIChatRequestModel(sessionId: sessionId, message: message);
      final response = await _remoteDataSource.sendMessage(request);
      return Result.success(response);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<AIChatMessage>>> getHistory(String sessionId) async {
    try {
      final history = await _remoteDataSource.getHistory(sessionId);
      return Result.success(history);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }
}

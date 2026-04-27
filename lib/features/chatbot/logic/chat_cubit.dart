import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:doctor_appointment/features/chatbot/domain/entities/ai_chat_entity.dart';
import 'package:doctor_appointment/features/chatbot/domain/usecases/start_new_chat_usecase.dart';
import 'package:doctor_appointment/features/chatbot/domain/usecases/get_ai_chat_history_usecase.dart';
import 'package:doctor_appointment/features/chatbot/domain/usecases/send_ai_chat_message_usecase.dart';
import 'package:doctor_appointment/core/utils/result.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final StartNewChatUseCase _startNewChatUseCase;
  final GetAIChatHistoryUseCase _getAIChatHistoryUseCase;
  final SendAIChatMessageUseCase _sendAIChatMessageUseCase;

  String? _currentSessionId;

  ChatCubit({
    required StartNewChatUseCase startNewChatUseCase,
    required GetAIChatHistoryUseCase getAIChatHistoryUseCase,
    required SendAIChatMessageUseCase sendAIChatMessageUseCase,
  })  : _startNewChatUseCase = startNewChatUseCase,
        _getAIChatHistoryUseCase = getAIChatHistoryUseCase,
        _sendAIChatMessageUseCase = sendAIChatMessageUseCase,
        super(const ChatState());

  Future<void> initChat({String? sessionId}) async {
    if (sessionId != null) {
      _currentSessionId = sessionId;
      await _loadHistory(sessionId);
    } else {
      await _startNewChat();
    }
  }

  Future<void> _startNewChat() async {
    emit(state.copyWith(status: ChatStatus.loading));
    final result = await _startNewChatUseCase();
    
    if (result is Success<String>) {
      _currentSessionId = result.data;
      emit(state.copyWith(status: ChatStatus.ready, messages: []));
    } else if (result is FailureResult<String>) {
      emit(state.copyWith(status: ChatStatus.error, errorMessage: result.failure.message));
    }
  }

  Future<void> _loadHistory(String sessionId) async {
    emit(state.copyWith(status: ChatStatus.loading));
    final result = await _getAIChatHistoryUseCase(sessionId);
    
    if (result is Success<List<AIChatMessage>>) {
      emit(state.copyWith(status: ChatStatus.ready, messages: result.data));
    } else if (result is FailureResult<List<AIChatMessage>>) {
      emit(state.copyWith(status: ChatStatus.error, errorMessage: result.failure.message));
    }
  }

  Future<void> sendMessage(String message) async {
    if (_currentSessionId == null) return;
    if (message.trim().isEmpty) return;

    emit(state.copyWith(status: ChatStatus.sending, pendingUserMessage: message));

    final result = await _sendAIChatMessageUseCase(_currentSessionId!, message);
    
    if (result is Success<AIChatResponse>) {
      final response = result.data;
      final newMessage = AIChatMessage(
        sessionId: response.sessionId,
        userMessage: response.userMessage,
        aiMessage: response.aiMessage,
        createdAt: response.createdAt,
      );
      final updatedMessages = List<AIChatMessage>.from(state.messages)..add(newMessage);
      emit(state.copyWith(status: ChatStatus.ready, messages: updatedMessages, clearPendingUserMessage: true));
    } else if (result is FailureResult<AIChatResponse>) {
      emit(state.copyWith(status: ChatStatus.error, errorMessage: result.failure.message, clearPendingUserMessage: true));
    }
  }
}

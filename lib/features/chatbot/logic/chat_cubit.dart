import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:doctor_appointment/features/chatbot/domain/entities/ai_chat_entity.dart';
import 'package:doctor_appointment/features/chatbot/domain/usecases/start_new_chat_usecase.dart';
import 'package:doctor_appointment/features/chatbot/domain/usecases/get_ai_chat_history_usecase.dart';
import 'package:doctor_appointment/features/chatbot/domain/usecases/send_ai_chat_message_usecase.dart';
import 'package:doctor_appointment/features/doctors/domain/usecases/search_doctors_usecase.dart';
import 'package:doctor_appointment/features/doctors/domain/usecases/get_specializations_usecase.dart';
import 'package:doctor_appointment/features/doctors/domain/entities/doctors_page.dart';
import 'package:doctor_appointment/core/utils/result.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final StartNewChatUseCase _startNewChatUseCase;
  final GetAIChatHistoryUseCase _getAIChatHistoryUseCase;
  final SendAIChatMessageUseCase _sendAIChatMessageUseCase;
  final SearchDoctorsUseCase _searchDoctorsUseCase;
  final GetSpecializationsUseCase _getSpecializationsUseCase;

  String? _currentSessionId;

  ChatCubit({
    required StartNewChatUseCase startNewChatUseCase,
    required GetAIChatHistoryUseCase getAIChatHistoryUseCase,
    required SendAIChatMessageUseCase sendAIChatMessageUseCase,
    required SearchDoctorsUseCase searchDoctorsUseCase,
    required GetSpecializationsUseCase getSpecializationsUseCase,
  }) : _startNewChatUseCase = startNewChatUseCase,
       _getAIChatHistoryUseCase = getAIChatHistoryUseCase,
       _sendAIChatMessageUseCase = sendAIChatMessageUseCase,
       _searchDoctorsUseCase = searchDoctorsUseCase,
       _getSpecializationsUseCase = getSpecializationsUseCase,
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

    if (result is Success<NewChatResponse>) {
      _currentSessionId = result.data.sessionId;
      // Provide a welcome message as the first AI message locally
      final welcomeMessage = AIChatMessage(
        sessionId: _currentSessionId!,
        userMessage: "", // It's just a welcome
        aiMessage: result.data.welcomeMessageEn, // Or Ar based on locale
        createdAt: DateTime.now(),
      );
      emit(
        state.copyWith(status: ChatStatus.ready, messages: [welcomeMessage]),
      );
    } else if (result is FailureResult<NewChatResponse>) {
      emit(
        state.copyWith(
          status: ChatStatus.error,
          errorMessage: result.failure.message,
        ),
      );
    }
  }

  Future<void> _loadHistory(String sessionId) async {
    emit(state.copyWith(status: ChatStatus.loading));
    final result = await _getAIChatHistoryUseCase(sessionId);

    if (result is Success<List<AIChatMessage>>) {
      emit(state.copyWith(status: ChatStatus.ready, messages: result.data));
    } else if (result is FailureResult<List<AIChatMessage>>) {
      emit(
        state.copyWith(
          status: ChatStatus.error,
          errorMessage: result.failure.message,
        ),
      );
    }
  }

  Future<void> sendMessage(String message) async {
    if (_currentSessionId == null) return;
    if (message.trim().isEmpty) return;

    emit(
      state.copyWith(status: ChatStatus.sending, pendingUserMessage: message),
    );

    final result = await _sendAIChatMessageUseCase(
      sessionId: _currentSessionId!,
      message: message,
    );

    await _handleSendResponse(result);
  }

  Future<void> _handleSendResponse(Result<AIChatResponse> result) async {
    if (result is Success<AIChatResponse>) {
      final response = result.data;

      if (response.type == 'get_doctors') {
        // AI detected doctor intent. Fetch doctors.
        final params = response.searchParams;
        String searchTerm = "";
        int? specId;

        if (params?.specialization != null) {
          // Fetch specializations and match by name to get the ID
          try {
            final specs = await _getSpecializationsUseCase();
            final matchedSpec = specs.firstWhere(
              (s) =>
                  s.name.toLowerCase() == params!.specialization!.toLowerCase(),
              orElse: () => specs.firstWhere(
                (s) => s.name.toLowerCase().contains(
                  params!.specialization!.toLowerCase(),
                ),
                orElse: () => throw Exception('No match'),
              ),
            );
            specId = matchedSpec.id;
          } catch (_) {
            // No matching specialization found — fallback to free text search
            searchTerm += params!.specialization!;
          }
        }

        if (params?.location != null) {
          searchTerm += " ${params!.location!}";
        }

        final doctorsResult = await _searchDoctorsUseCase(
          SearchDoctorsParams(
            specializationId: specId,
            searchTerm: searchTerm.trim().isEmpty ? null : searchTerm.trim(),
            minRating: params?.minRating,
          ),
        );

        List<Map<String, dynamic>> doctorList = [];
        if (doctorsResult is Success<DoctorsPage>) {
          final page = doctorsResult.data;
          doctorList = page.items
              .map(
                (doc) => {
                  'id': doc.id.toString(),
                  'name': doc.fullName,
                  'specialization': doc.specialization.name,
                  'location': doc.clinicAddress ?? doc.hospital ?? "Unknown",
                  'rating': doc.averageRating ?? 0.0,
                  'available': doc.isAvailable,
                },
              )
              .toList();
        }

        // Send tool result back to AI
        final turn2Result = await _sendAIChatMessageUseCase(
          sessionId: _currentSessionId!,
          message: "",
          toolResult: {"tool": "get_doctors", "doctors": doctorList},
        );

        await _handleSendResponse(turn2Result);
      } else {
        // Normal chat response
        final newMessage = AIChatMessage(
          sessionId: response.sessionId,
          userMessage: response.userMessage,
          aiMessage: response.aiMessage,
          createdAt: response.createdAt,
        );
        final updatedMessages = List<AIChatMessage>.from(state.messages)
          ..add(newMessage);

        emit(
          state.copyWith(
            status: ChatStatus.ready,
            messages: updatedMessages,
            clearPendingUserMessage: true,
            currentUi: response.ui,
            currentStructuredReport: response.structured,
            currentRiskLevel: response.riskLevel,
          ),
        );
      }
    } else if (result is FailureResult<AIChatResponse>) {
      if (result.failure.message.contains('limit')) {
        emit(
          state.copyWith(
            status: ChatStatus.limitReached,
            errorMessage: result.failure.message,
            clearPendingUserMessage: true,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: ChatStatus.error,
            errorMessage: result.failure.message,
            clearPendingUserMessage: true,
          ),
        );
      }
    }
  }
}

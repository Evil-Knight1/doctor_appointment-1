import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:doctor_appointment/features/chatbot/domain/usecases/get_user_chats_usecase.dart';
import 'package:doctor_appointment/core/utils/result.dart';

part 'chat_history_state.dart';

class ChatHistoryCubit extends Cubit<ChatHistoryState> {
  final GetUserChatsUseCase _getUserChatsUseCase;

  ChatHistoryCubit(this._getUserChatsUseCase) : super(ChatHistoryInitial());

  Future<void> fetchUserChats() async {
    emit(ChatHistoryLoading());
    final result = await _getUserChatsUseCase();
    
    if (result is Success<List<String>>) {
      emit(ChatHistoryLoaded(result.data));
    } else if (result is FailureResult<List<String>>) {
      emit(ChatHistoryError(result.failure.message));
    }
  }
}

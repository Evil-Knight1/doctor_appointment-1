import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doctor_appointment/core/utils/result.dart';
import 'package:doctor_appointment/features/appointment/domain/usecases/get_my_appointments_usecase.dart';
import 'package:doctor_appointment/features/appointment/logic/appointments_state.dart';

class AppointmentsCubit extends Cubit<AppointmentsState> {
  final GetMyAppointmentsUseCase getMyAppointmentsUseCase;

  AppointmentsCubit({required this.getMyAppointmentsUseCase})
      : super(const AppointmentsInitial());

  Future<void> loadAppointments() async {
    emit(const AppointmentsLoading());
    final result = await getMyAppointmentsUseCase();

    switch (result) {
      case Success():
        emit(AppointmentsSuccess(result.data));
      case FailureResult():
        emit(AppointmentsFailure(result.failure.message));
    }
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doctor_appointment/core/utils/result.dart';
import 'package:doctor_appointment/features/doctor_flow/domain/usecases/get_doctor_appointments_usecase.dart';
import 'package:doctor_appointment/features/doctor_flow/logic/doctor_appointments_state.dart';

class DoctorAppointmentsCubit extends Cubit<DoctorAppointmentsState> {
  final GetDoctorAppointmentsUseCase getDoctorAppointmentsUseCase;

  DoctorAppointmentsCubit({required this.getDoctorAppointmentsUseCase})
      : super(DoctorAppointmentsInitial());

  Future<void> fetchAppointments() async {
    emit(DoctorAppointmentsLoading());
    final result = await getDoctorAppointmentsUseCase();
    
    switch (result) {
      case Success():
        emit(DoctorAppointmentsSuccess(result.data));
      case FailureResult():
        emit(DoctorAppointmentsFailure(result.failure.message));
    }
  }
}

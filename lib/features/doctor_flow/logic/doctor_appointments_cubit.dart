import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doctor_appointment/core/utils/result.dart';
import 'package:doctor_appointment/features/doctor_flow/domain/usecases/get_doctor_appointments_usecase.dart';
import 'package:doctor_appointment/features/doctor_flow/domain/usecases/update_appointment_status_usecase.dart';
import 'package:doctor_appointment/features/doctor_flow/logic/doctor_appointments_state.dart';
import 'package:doctor_appointment/features/appointment/domain/entities/appointment.dart';

import 'package:doctor_appointment/core/errors/failures.dart';

import 'package:doctor_appointment/features/appointment/domain/usecases/doctor_approve_reschedule_usecase.dart';

class DoctorAppointmentsCubit extends Cubit<DoctorAppointmentsState> {
  final GetDoctorAppointmentsUseCase getDoctorAppointmentsUseCase;
  final UpdateAppointmentStatusUseCase updateAppointmentStatusUseCase;
  final DoctorApproveRescheduleUseCase doctorApproveRescheduleUseCase;

  DoctorAppointmentsCubit({
    required this.getDoctorAppointmentsUseCase,
    required this.updateAppointmentStatusUseCase,
    required this.doctorApproveRescheduleUseCase,
  }) : super(DoctorAppointmentsInitial());

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

  Future<Result<Appointment>> updateStatus(int appointmentId, int status, {String? notes}) async {
    final currentState = state;
    if (currentState is DoctorAppointmentsSuccess) {
      final result = await updateAppointmentStatusUseCase(appointmentId, status, notes: notes);
      
      switch (result) {
        case Success():
          final updatedList = currentState.appointments.map((app) {
            if (app.id == appointmentId) {
              return Appointment(
                id: app.id,
                patientId: app.patientId,
                patientName: app.patientName,
                doctorId: app.doctorId,
                doctorName: app.doctorName,
                startTime: app.startTime,
                endTime: app.endTime,
                reason: app.reason,
                status: status,
                isPaid: app.isPaid,
                paymentMethod: app.paymentMethod,
                paymentStatus: app.paymentStatus,
                paymentTransactionId: app.paymentTransactionId,
                paymentDate: app.paymentDate,
                amount: app.amount,
                doctorNotes: notes ?? app.doctorNotes,
                specializationName: app.specializationName,
                doctorProfilePicture: app.doctorProfilePicture,
                patientProfilePicture: app.patientProfilePicture,
                createdAt: app.createdAt,
              );
            }
            return app;
          }).toList();
          emit(DoctorAppointmentsSuccess(updatedList));
          return Result.success(result.data);
        case FailureResult():
          return Result.failure(result.failure);
      }
    }
    return Result.failure(const ServerFailure('Unable to update status: invalid state'));
  }

  Future<Result<void>> approveReschedule(int appointmentId) async {
    final result = await doctorApproveRescheduleUseCase(appointmentId);
    if (result is Success) {
      await fetchAppointments();
    }
    return result;
  }
}

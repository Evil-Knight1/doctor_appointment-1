import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doctor_appointment/core/utils/result.dart';
import 'package:doctor_appointment/core/services/app_cache_service.dart';
import 'package:doctor_appointment/features/appointment/data/models/appointment_model.dart';
import 'package:doctor_appointment/features/appointment/domain/usecases/get_my_appointments_usecase.dart';
import 'package:doctor_appointment/features/appointment/domain/usecases/cancel_appointment_usecase.dart';
import 'package:doctor_appointment/features/appointment/logic/appointments_state.dart';

import 'package:doctor_appointment/features/appointment/domain/usecases/request_cancel_usecase.dart';
import 'package:doctor_appointment/features/appointment/domain/usecases/request_reschedule_usecase.dart';
import 'package:doctor_appointment/features/appointment/domain/usecases/select_reschedule_slot_usecase.dart';

class AppointmentsCubit extends Cubit<AppointmentsState> {
  final GetMyAppointmentsUseCase getMyAppointmentsUseCase;
  final CancelAppointmentUseCase cancelAppointmentUseCase;
  final RequestCancelUseCase requestCancelUseCase;
  final RequestRescheduleUseCase requestRescheduleUseCase;
  final SelectRescheduleSlotUseCase selectRescheduleSlotUseCase;
  final AppCacheService appCacheService;

  AppointmentsCubit({
    required this.getMyAppointmentsUseCase,
    required this.cancelAppointmentUseCase,
    required this.requestCancelUseCase,
    required this.requestRescheduleUseCase,
    required this.selectRescheduleSlotUseCase,
    required this.appCacheService,
  }) : super(const AppointmentsInitial());

  Future<void> loadAppointments() async {
    emit(const AppointmentsLoading());

    final cachedAppointments = appCacheService.getCachedAppointments();
    if (cachedAppointments.isNotEmpty) {
      emit(AppointmentsSuccess(cachedAppointments));
    }

    final result = await getMyAppointmentsUseCase();

    switch (result) {
      case Success():
        await appCacheService.cacheAppointments(result.data.cast<AppointmentModel>());
        emit(AppointmentsSuccess(result.data));
      case FailureResult():
        if (cachedAppointments.isEmpty) {
          emit(AppointmentsFailure(result.failure.message));
        }
    }
  }

  Future<Result<void>> cancelAppointment(int appointmentId) async {
    final result = await cancelAppointmentUseCase(appointmentId);

    if (result is Success) {
      // Reload appointments after successful cancellation
      await loadAppointments();
    }
    return result;
  }

  Future<Result<void>> requestCancel(int appointmentId, String reason) async {
    final result = await requestCancelUseCase(appointmentId, reason);
    if (result is Success) {
      await loadAppointments();
    }
    return result;
  }

  Future<Result<void>> requestReschedule(int appointmentId, String reason) async {
    final result = await requestRescheduleUseCase(appointmentId, reason);
    if (result is Success) {
      await loadAppointments();
    }
    return result;
  }

  Future<Result<void>> selectRescheduleSlot(int appointmentId, int newSlotId) async {
    final result = await selectRescheduleSlotUseCase(appointmentId, newSlotId);
    if (result is Success) {
      await loadAppointments();
    }
    return result;
  }
}

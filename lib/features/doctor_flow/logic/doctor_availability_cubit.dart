import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doctor_appointment/features/doctor_flow/domain/repositories/doctor_stats_repository.dart';
import 'package:doctor_appointment/features/doctor_flow/logic/doctor_availability_state.dart';
import 'package:doctor_appointment/core/utils/result.dart';

class DoctorAvailabilityCubit extends Cubit<DoctorAvailabilityState> {
  final DoctorStatsRepository repository;

  DoctorAvailabilityCubit(this.repository) : super(DoctorAvailabilityInitial());

  Future<void> fetchAvailability(int doctorId) async {
    emit(DoctorAvailabilityLoading());
    final res = await repository.getDoctorAvailability(doctorId);
    switch (res) {
      case Success():
        emit(DoctorAvailabilitySuccess(res.data));
      case FailureResult():
        emit(DoctorAvailabilityFailure(res.failure.message));
    }
  }

  Future<bool> addAvailability({
    required int doctorId,
    required int dayOfWeek,
    required String startTime,
    required String endTime,
    required int durationMinutes,
    required double price,
    required double consultationPrice,
  }) async {
    final data = {
      'dayOfWeek': dayOfWeek,
      'startTime': startTime,
      'endTime': endTime,
      'isAvailable': true,
      'startDate': DateTime.now().toIso8601String(),
      'endDate': DateTime.now().add(const Duration(days: 365)).toIso8601String(),
      'durationMinutes': durationMinutes,
      'price': price,
      'consultationPrice': consultationPrice,
    };
    final res = await repository.addAvailability(data);
    switch (res) {
      case Success():
        await fetchAvailability(doctorId);
        return true;
      case FailureResult():
        emit(DoctorAvailabilityFailure(res.failure.message));
        return false;
    }
  }

  Future<bool> updateAvailability({
    required int doctorId,
    required int availabilityId,
    required String startTime,
    required String endTime,
    required int durationMinutes,
    required double price,
    required double consultationPrice,
  }) async {
    final data = {
      'startTime': startTime,
      'endTime': endTime,
      'isAvailable': true,
      'durationMinutes': durationMinutes,
      'price': price,
      'consultationPrice': consultationPrice,
    };
    final res = await repository.updateAvailability(availabilityId, data);
    switch (res) {
      case Success():
        await fetchAvailability(doctorId);
        return true;
      case FailureResult():
        emit(DoctorAvailabilityFailure(res.failure.message));
        return false;
    }
  }
}

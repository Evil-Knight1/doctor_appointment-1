import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doctor_appointment/core/utils/result.dart';
import 'package:doctor_appointment/features/appointment/domain/usecases/get_doctor_slots_usecase.dart';
import 'package:doctor_appointment/features/appointment/logic/doctor_slots_state.dart';

class DoctorSlotsCubit extends Cubit<DoctorSlotsState> {
  final GetDoctorSlotsUseCase getDoctorSlotsUseCase;

  DoctorSlotsCubit({required this.getDoctorSlotsUseCase})
    : super(const DoctorSlotsInitial());

  Future<void> fetchSlots(int doctorId, DateTime date) async {
    emit(const DoctorSlotsLoading());
    final result = await getDoctorSlotsUseCase(
      GetDoctorSlotsParams(doctorId: doctorId, date: date),
    );

    switch (result) {
      case Success():
        emit(DoctorSlotsLoaded(result.data));
      case FailureResult():
        emit(DoctorSlotsError(result.failure.message));
    }
  }
}

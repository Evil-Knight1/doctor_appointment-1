import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doctor_appointment/core/utils/result.dart';
import 'package:doctor_appointment/features/appointment/domain/usecases/create_appointment_usecase.dart';
import 'package:doctor_appointment/features/appointment/logic/appointment_state.dart';

class AppointmentCubit extends Cubit<AppointmentState> {
  final CreateAppointmentUseCase createAppointmentUseCase;

  AppointmentCubit({required this.createAppointmentUseCase})
    : super(const AppointmentInitial());

  Future<void> createAppointment({
    required int doctorId,
    required int slotId,
    required String reason,
    int? paymentMethod,
    double? amount,
  }) async {
    emit(const AppointmentLoading());
    final result = await createAppointmentUseCase(
      CreateAppointmentParams(
        doctorId: doctorId,
        slotId: slotId,
        reason: reason,
        paymentMethod: paymentMethod,
        amount: amount,
      ),
    );

    switch (result) {
      case Success():
        emit(AppointmentSuccess(result.data));
      case FailureResult():
        emit(AppointmentFailure(result.failure.message));
    }
  }
}

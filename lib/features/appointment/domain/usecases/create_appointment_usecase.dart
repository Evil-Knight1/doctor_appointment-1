import 'package:doctor_appointment/core/utils/result.dart';
import 'package:doctor_appointment/features/appointment/domain/entities/appointment.dart';
import 'package:doctor_appointment/features/appointment/domain/repositories/appointment_repository.dart';

class CreateAppointmentUseCase {
  final AppointmentRepository repository;

  const CreateAppointmentUseCase(this.repository);

  Future<Result<Appointment>> call(CreateAppointmentParams params) {
    return repository.createAppointment(
      doctorId: params.doctorId,
      slotId: params.slotId,
      reason: params.reason,
      paymentMethod: params.paymentMethod,
      amount: params.amount,
    );
  }
}

class CreateAppointmentParams {
  final int doctorId;
  final int slotId;
  final String reason;
  final int? paymentMethod;
  final double? amount;

  const CreateAppointmentParams({
    required this.doctorId,
    required this.slotId,
    required this.reason,
    this.paymentMethod,
    this.amount,
  });
}

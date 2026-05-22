import 'package:doctor_appointment/core/utils/result.dart';
import 'package:doctor_appointment/features/appointment/domain/repositories/appointment_repository.dart';

class RequestRescheduleUseCase {
  final AppointmentRepository _repository;

  const RequestRescheduleUseCase(this._repository);

  Future<Result<void>> call(int appointmentId, String reason) {
    return _repository.requestReschedule(appointmentId, reason);
  }
}

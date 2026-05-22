import 'package:doctor_appointment/core/utils/result.dart';
import 'package:doctor_appointment/features/appointment/domain/repositories/appointment_repository.dart';

class AdminCancelUseCase {
  final AppointmentRepository _repository;

  const AdminCancelUseCase(this._repository);

  Future<Result<void>> call(int appointmentId) {
    return _repository.adminCancel(appointmentId);
  }
}

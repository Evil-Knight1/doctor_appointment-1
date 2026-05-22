import 'package:doctor_appointment/core/utils/result.dart';
import 'package:doctor_appointment/features/appointment/domain/repositories/appointment_repository.dart';

class DoctorApproveRescheduleUseCase {
  final AppointmentRepository _repository;

  const DoctorApproveRescheduleUseCase(this._repository);

  Future<Result<void>> call(int appointmentId) {
    return _repository.doctorApproveReschedule(appointmentId);
  }
}

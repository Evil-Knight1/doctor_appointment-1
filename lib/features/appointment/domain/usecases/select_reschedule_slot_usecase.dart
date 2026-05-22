import 'package:doctor_appointment/core/utils/result.dart';
import 'package:doctor_appointment/features/appointment/domain/repositories/appointment_repository.dart';

class SelectRescheduleSlotUseCase {
  final AppointmentRepository _repository;

  const SelectRescheduleSlotUseCase(this._repository);

  Future<Result<void>> call(int appointmentId, int newSlotId) {
    return _repository.selectRescheduleSlot(appointmentId, newSlotId);
  }
}

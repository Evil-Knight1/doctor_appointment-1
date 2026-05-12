import 'package:doctor_appointment/core/utils/result.dart';
import 'package:doctor_appointment/features/appointment/data/models/slot_model.dart';
import 'package:doctor_appointment/features/appointment/domain/repositories/appointment_repository.dart';

class GetDoctorSlotsUseCase {
  final AppointmentRepository repository;

  const GetDoctorSlotsUseCase(this.repository);

  Future<Result<List<SlotModel>>> call(int doctorId) {
    return repository.getDoctorSlots(doctorId);
  }
}

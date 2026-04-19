import 'package:doctor_appointment/core/utils/result.dart';
import 'package:doctor_appointment/features/appointment/domain/entities/appointment.dart';
import 'package:doctor_appointment/features/appointment/domain/repositories/appointment_repository.dart';

class GetMyAppointmentsUseCase {
  final AppointmentRepository repository;

  const GetMyAppointmentsUseCase(this.repository);

  Future<Result<List<Appointment>>> call() {
    return repository.getMyAppointments();
  }
}

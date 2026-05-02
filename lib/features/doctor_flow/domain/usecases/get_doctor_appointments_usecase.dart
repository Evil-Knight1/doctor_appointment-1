import 'package:doctor_appointment/core/utils/result.dart';
import 'package:doctor_appointment/features/doctor_flow/domain/repositories/doctor_stats_repository.dart';
import 'package:doctor_appointment/features/appointment/domain/entities/appointment.dart';

class GetDoctorAppointmentsUseCase {
  final DoctorStatsRepository repository;
  GetDoctorAppointmentsUseCase(this.repository);

  Future<Result<List<Appointment>>> call() {
    return repository.getDoctorAppointments();
  }
}

import 'package:doctor_appointment/features/doctor_flow/domain/entities/doctor_stats.dart';
import 'package:doctor_appointment/features/doctors/domain/entities/doctor.dart';
import 'package:doctor_appointment/features/appointment/domain/entities/appointment.dart';
import 'package:doctor_appointment/core/utils/result.dart';

abstract class DoctorStatsRepository {
  Future<Result<DoctorStats>> getDoctorStats();
  Future<Result<Doctor>> getDoctorProfile();
  Future<Result<List<Appointment>>> getDoctorAppointments();
}

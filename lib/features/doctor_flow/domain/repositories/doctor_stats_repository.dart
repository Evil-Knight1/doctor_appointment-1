import 'package:doctor_appointment/features/doctor_flow/domain/entities/doctor_stats.dart';
import 'package:doctor_appointment/features/doctors/domain/entities/doctor.dart';
import 'package:doctor_appointment/features/appointment/domain/entities/appointment.dart';
import 'package:doctor_appointment/features/doctor_flow/domain/entities/doctor_monthly_revenue.dart';
import 'package:doctor_appointment/features/doctor_flow/domain/entities/doctor_daily_revenue.dart';
import 'package:doctor_appointment/features/doctors/data/models/availability_model.dart';
import 'package:doctor_appointment/core/utils/result.dart';

abstract class DoctorStatsRepository {
  Future<Result<DoctorStats>> getDoctorStats();
  Future<Result<Doctor>> getDoctorProfile();
  Future<Result<List<Appointment>>> getDoctorAppointments();
  Future<Result<Doctor>> updateDoctorProfile(Map<String, dynamic> data);
  Future<Result<Appointment>> updateAppointmentStatus(int appointmentId, int status, {String? notes});
  Future<Result<List<DoctorMonthlyRevenue>>> getMonthlyRevenue(int year);
  Future<Result<List<DoctorDailyRevenue>>> getDailyRevenue(int year, int month);
  Future<Result<List<AvailabilityModel>>> getDoctorAvailability(int doctorId);
  Future<Result<AvailabilityModel>> addAvailability(Map<String, dynamic> data);
  Future<Result<AvailabilityModel>> updateAvailability(int availabilityId, Map<String, dynamic> data);
}

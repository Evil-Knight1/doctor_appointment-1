import 'package:doctor_appointment/features/doctor_flow/domain/entities/doctor_stats.dart';

abstract class DoctorStatsRepository {
  Future<DoctorStats> getDoctorStats();
}

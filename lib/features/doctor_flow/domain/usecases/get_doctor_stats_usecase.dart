import 'package:doctor_appointment/core/utils/result.dart';
import 'package:doctor_appointment/features/doctor_flow/domain/entities/doctor_stats.dart';
import 'package:doctor_appointment/features/doctor_flow/domain/repositories/doctor_stats_repository.dart';

class GetDoctorStatsUseCase {
  final DoctorStatsRepository repository;
  const GetDoctorStatsUseCase(this.repository);

  Future<Result<DoctorStats>> call() => repository.getDoctorStats();
}

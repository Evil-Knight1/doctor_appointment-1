import 'package:doctor_appointment/core/utils/result.dart';
import 'package:doctor_appointment/features/doctor_flow/domain/repositories/doctor_stats_repository.dart';
import 'package:doctor_appointment/features/doctors/domain/entities/doctor.dart';

class GetDoctorProfileUseCase {
  final DoctorStatsRepository repository;
  GetDoctorProfileUseCase(this.repository);

  Future<Result<Doctor>> call() {
    return repository.getDoctorProfile();
  }
}

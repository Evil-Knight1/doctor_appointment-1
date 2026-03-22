import 'package:doctor_appointment/core/utils/result.dart';
import 'package:doctor_appointment/features/profile/domain/entities/patient_profile.dart';
import 'package:doctor_appointment/features/profile/domain/repositories/profile_repository.dart';

class GetPatientProfileUseCase {
  final ProfileRepository repository;

  const GetPatientProfileUseCase(this.repository);

  Future<Result<PatientProfile>> call() {
    return repository.getPatientProfile();
  }
}

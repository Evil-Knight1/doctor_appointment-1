import 'package:doctor_appointment/core/utils/result.dart';
import 'package:doctor_appointment/features/profile/domain/entities/patient_profile.dart';
import 'package:doctor_appointment/features/profile/domain/repositories/profile_repository.dart';

class UpdatePatientProfileUseCase {
  final ProfileRepository repository;

  const UpdatePatientProfileUseCase(this.repository);

  Future<Result<PatientProfile>> call(UpdatePatientProfileParams params) {
    return repository.updatePatientProfile(
      fullName: params.fullName,
      phone: params.phone,
      dateOfBirth: params.dateOfBirth,
      gender: params.gender,
      address: params.address,
    );
  }
}

class UpdatePatientProfileParams {
  final String fullName;
  final String phone;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? address;

  const UpdatePatientProfileParams({
    required this.fullName,
    required this.phone,
    this.dateOfBirth,
    this.gender,
    this.address,
  });
}

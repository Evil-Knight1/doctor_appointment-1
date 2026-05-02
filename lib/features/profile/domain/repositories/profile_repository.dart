import 'package:doctor_appointment/core/utils/result.dart';
import 'package:doctor_appointment/features/profile/domain/entities/patient_profile.dart';

abstract class ProfileRepository {
  Future<Result<PatientProfile>> getPatientProfile();

  Future<Result<PatientProfile>> updatePatientProfile({
    required String fullName,
    required String phone,
    DateTime? dateOfBirth,
    String? gender,
    String? address,
    String? profilePicturePath,
  });
}

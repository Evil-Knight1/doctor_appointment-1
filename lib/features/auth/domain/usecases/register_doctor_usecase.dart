import 'package:doctor_appointment/core/utils/result.dart';
import 'package:doctor_appointment/features/auth/domain/entities/auth_response.dart';
import 'package:doctor_appointment/features/auth/domain/repositories/auth_repository.dart';

class RegisterDoctorUseCase {
  final AuthRepository repository;

  RegisterDoctorUseCase(this.repository);

  Future<Result<AuthResponse>> call(RegisterDoctorParams params) {
    return repository.registerDoctor(
      fullName: params.fullName,
      email: params.email,
      phone: params.phone,
      password: params.password,
      specializations: params.specializations,
      experienceYears: params.experienceYears,
      licenseId: params.licenseId,
      clinicAddress: params.clinicAddress,
      hospitalName: params.hospitalName,
      bio: params.bio,
    );
  }
}

class RegisterDoctorParams {
  final String fullName;
  final String email;
  final String phone;
  final String password;
  final List<String> specializations;
  final int experienceYears;
  final String licenseId;
  final String clinicAddress;
  final String hospitalName;
  final String? bio;

  RegisterDoctorParams({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.password,
    required this.specializations,
    required this.experienceYears,
    required this.licenseId,
    required this.clinicAddress,
    required this.hospitalName,
    this.bio,
  });
}

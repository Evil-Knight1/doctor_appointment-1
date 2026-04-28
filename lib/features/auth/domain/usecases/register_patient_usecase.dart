import 'package:doctor_appointment/core/utils/result.dart';
import 'package:doctor_appointment/features/auth/domain/entities/auth_response.dart';
import 'package:doctor_appointment/features/auth/domain/repositories/auth_repository.dart';

class RegisterPatientUseCase {
  final AuthRepository repository;

  const RegisterPatientUseCase(this.repository);

  Future<Result<AuthResponse>> call(RegisterPatientParams params) {
    return repository.registerPatient(
      fullName: params.fullName,
      email: params.email,
      phone: params.phone,
      password: params.password,
      dateOfBirth: params.dateOfBirth,
      gender: params.gender,
      address: params.address,
      profilePicturePath: params.profilePicturePath,
    );
  }
}

class RegisterPatientParams {
  final String fullName;
  final String email;
  final String phone;
  final String password;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? address;
  final String? profilePicturePath;

  const RegisterPatientParams({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.password,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.profilePicturePath,
  });
}

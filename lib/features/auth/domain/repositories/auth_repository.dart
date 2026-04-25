import 'package:doctor_appointment/core/utils/result.dart';
import 'package:doctor_appointment/features/auth/domain/entities/auth_response.dart';

abstract class AuthRepository {
  Future<Result<AuthResponse>> login({
    required String email,
    required String password,
  });

  Future<Result<AuthResponse>> registerPatient({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    DateTime? dateOfBirth,
    String? gender,
    String? address,
  });

  Future<Result<AuthResponse>> refreshToken({
    required String token,
    required String refreshToken,
  });

  Future<Result<AuthResponse?>> getCachedSession();

  Future<Result<AuthResponse>> registerDoctor({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required List<String> specializations,
    required int experienceYears,
    required String licenseId,
    required String clinicAddress,
    required String hospitalName,
    String? bio,
  });
}

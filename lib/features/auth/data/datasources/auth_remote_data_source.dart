import 'package:doctor_appointment/core/errors/exceptions.dart';
import 'package:doctor_appointment/core/services/api_service.dart';
import 'package:doctor_appointment/features/auth/data/models/auth_response_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  });

  Future<AuthResponseModel> registerPatient({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    DateTime? dateOfBirth,
    String? gender,
    String? address,
  });

  Future<AuthResponseModel> refreshToken({
    required String token,
    required String refreshToken,
  });

  Future<AuthResponseModel> registerDoctor({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required int specializationId,
    required int experienceYears,
    required String licenseId,
    required String clinicAddress,
    required String hospitalName,
    String? bio,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiService apiService;

  AuthRemoteDataSourceImpl(this.apiService);

  @override
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    final response = await apiService.post(
      '/api/Auth/login',
      data: {'email': email, 'password': password},
    );
    return _parseAuthResponse(response);
  }

  @override
  Future<AuthResponseModel> registerPatient({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    DateTime? dateOfBirth,
    String? gender,
    String? address,
  }) async {
    final response = await apiService.post(
      '/api/Auth/register/patient',
      data: {
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'password': password,
        'dateOfBirth': dateOfBirth?.toIso8601String(),
        'gender': gender,
        'address': address,
      },
    );
    return _parseAuthResponse(response);
  }

  @override
  Future<AuthResponseModel> refreshToken({
    required String token,
    required String refreshToken,
  }) async {
    final response = await apiService.post(
      '/api/Auth/refresh',
      data: {'token': token, 'refreshToken': refreshToken},
    );
    return _parseAuthResponse(response);
  }

  @override
  Future<AuthResponseModel> registerDoctor({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required int specializationId,
    required int experienceYears,
    required String licenseId,
    required String clinicAddress,
    required String hospitalName,
    String? bio,
  }) async {
    final response = await apiService.post(
      '/api/Auth/register/doctor',
      data: {
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'password': password,
        'specializationId': specializationId,
        'yearsOfExperience': experienceYears,
        'licenseNumber': licenseId,
        'clinicAddress': clinicAddress.isEmpty ? null : clinicAddress,
        'hospital': hospitalName.isEmpty ? null : hospitalName,
        'bio': bio?.isEmpty == true ? null : bio,
      },
    );
    return _parseAuthResponse(response);
  }

  AuthResponseModel _parseAuthResponse(Map<String, dynamic> json) {
    final success = json['success'] == true;
    if (!success) {
      throw ApiException(_extractMessage(json));
    }

    final data = json['data'];
    if (data is Map<String, dynamic>) {
      return AuthResponseModel.fromJson(data);
    }

    throw const ApiException('Unexpected response payload');
  }

  String _extractMessage(Map<String, dynamic> json) {
    final message = json['message'] as String?;
    if (message != null && message.trim().isNotEmpty) {
      return message;
    }
    final errors = json['errors'];
    if (errors is List && errors.isNotEmpty) {
      return errors.map((e) => e.toString()).join(', ');
    }
    return 'Request failed';
  }
}

import 'package:dio/dio.dart';
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
    String? profilePicturePath,
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
    DateTime? dateOfBirth,
    String? gender,
    String? bio,
    String? profilePicturePath,
    List<String>? clinicImagesPaths,
  });

  Future<bool> updateFcmToken({required String fcmToken});

  Future<void> forgotPassword({required String email});
  
  Future<void> verifyOtp({required String email, required String otp});
  
  Future<void> resetPassword({
    required String email,
    required String token,
    required String newPassword,
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
    String? profilePicturePath,
  }) async {
    final Map<String, dynamic> data = {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'password': password,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'address': address,
    };

    if (profilePicturePath != null) {
      data['profilePicture'] = await MultipartFile.fromFile(
        profilePicturePath,
        filename: profilePicturePath.split('/').last,
      );
    }

    final response = await apiService.post(
      '/api/Auth/register/patient',
      data: FormData.fromMap(data),
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
    DateTime? dateOfBirth,
    String? gender,
    String? bio,
    String? profilePicturePath,
    List<String>? clinicImagesPaths,
  }) async {
    final Map<String, dynamic> data = {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'password': password,
      'specializationId': specializationId,
      'yearsOfExperience': experienceYears,
      'licenseNumber': licenseId,
      'clinicAddress': clinicAddress.isEmpty ? null : clinicAddress,
      'hospital': hospitalName.isEmpty ? null : hospitalName,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'bio': bio?.isEmpty == true ? null : bio,
    };

    if (profilePicturePath != null) {
      data['profilePicture'] = await MultipartFile.fromFile(
        profilePicturePath,
        filename: profilePicturePath.split('/').last,
      );
    }

    if (clinicImagesPaths != null && clinicImagesPaths.isNotEmpty) {
      data['clinicImages'] = await Future.wait(
        clinicImagesPaths.map(
          (path) => MultipartFile.fromFile(
            path,
            filename: path.split('/').last,
          ),
        ),
      );
    }

    final response = await apiService.post(
      '/api/Auth/register/doctor',
      data: FormData.fromMap(data),
    );
    return _parseAuthResponse(response);
  }

  @override
  Future<bool> updateFcmToken({required String fcmToken}) async {
    final response = await apiService.post(
      '/api/Auth/fcm-token',
      data: {'fcmToken': fcmToken},
    );
    return response['success'] == true;
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    final response = await apiService.post(
      '/api/Auth/forgot-password',
      data: {'email': email},
    );
    if (response['success'] != true) {
      final fieldErrors = _extractFieldErrors(response);
      final message = _extractMessage(response, fieldErrors);
      throw ApiException(message, fieldErrors: fieldErrors);
    }
  }

  @override
  Future<void> verifyOtp({required String email, required String otp}) async {
    final response = await apiService.post(
      '/api/Auth/verify-email',
      data: {'email': email, 'token': otp},
    );
    if (response['success'] != true) {
      final fieldErrors = _extractFieldErrors(response);
      final message = _extractMessage(response, fieldErrors);
      throw ApiException(message, fieldErrors: fieldErrors);
    }
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String token,
    required String newPassword,
  }) async {
    final response = await apiService.post(
      '/api/Auth/reset-password',
      data: {'email': email, 'token': token, 'newPassword': newPassword},
    );
    if (response['success'] != true) {
      final fieldErrors = _extractFieldErrors(response);
      final message = _extractMessage(response, fieldErrors);
      throw ApiException(message, fieldErrors: fieldErrors);
    }
  }

  AuthResponseModel _parseAuthResponse(Map<String, dynamic> json) {
    final success = json['success'] == true;
    if (!success) {
      final fieldErrors = _extractFieldErrors(json);
      final message = _extractMessage(json, fieldErrors);
      throw ApiException(message, fieldErrors: fieldErrors);
    }

    final data = json['data'];
    if (data is Map<String, dynamic>) {
      return AuthResponseModel.fromJson(data);
    }

    throw const ApiException('Unexpected response payload');
  }

  String _extractMessage(
    Map<String, dynamic> json,
    Map<String, String> fieldErrors,
  ) {
    final message = json['message'] as String?;
    if (message != null && message.trim().isNotEmpty) {
      return message;
    }
    // Flatten field errors into a readable message fallback
    if (fieldErrors.isNotEmpty) {
      return fieldErrors.values.first;
    }
    final errors = json['errors'];
    if (errors is List && errors.isNotEmpty) {
      return errors.map((e) => e.toString()).join(', ');
    }
    return 'Request failed';
  }

  /// Parses ASP.NET model-state / custom field errors.
  /// Supports two shapes:
  ///   1. { "errors": { "Password": ["Msg"], "Phone": ["Msg"] } }  (object of arrays)
  ///   2. { "errors": ["global error"] }  (flat list — no field mapping)
  Map<String, String> _extractFieldErrors(Map<String, dynamic> json) {
    final errors = json['errors'];
    if (errors is Map) {
      final result = <String, String>{};
      errors.forEach((key, value) {
        if (key is String) {
          if (value is List && value.isNotEmpty) {
            result[key.toLowerCase()] = value.first.toString();
          } else if (value is String && value.isNotEmpty) {
            result[key.toLowerCase()] = value;
          }
        }
      });
      return result;
    }
    return {};
  }
}

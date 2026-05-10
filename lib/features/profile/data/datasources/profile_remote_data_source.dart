import 'package:dio/dio.dart';
import 'package:doctor_appointment/core/errors/exceptions.dart';
import 'package:doctor_appointment/core/services/api_service.dart';
import 'package:doctor_appointment/features/profile/data/models/patient_profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<PatientProfileModel> getPatientProfile();

  Future<PatientProfileModel> updatePatientProfile({
    required String fullName,
    required String phone,
    DateTime? dateOfBirth,
    String? gender,
    String? address,
    String? profilePicturePath,
  });
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiService apiService;

  ProfileRemoteDataSourceImpl(this.apiService);

  @override
  Future<PatientProfileModel> getPatientProfile() async {
    final response = await apiService.get('/api/Patient/profile');
    
    dynamic data = response;
    if (response is Map<String, dynamic>) {
      if (response['success'] == false) {
        throw ApiException(_extractMessage(response));
      }
      data = response.containsKey('data') ? response['data'] : response;
    }

    if (data is Map<String, dynamic>) {
      return PatientProfileModel.fromJson(data);
    }

    throw const ApiException('Unexpected response payload');
  }

  @override
  Future<PatientProfileModel> updatePatientProfile({
    required String fullName,
    required String phone,
    DateTime? dateOfBirth,
    String? gender,
    String? address,
    String? profilePicturePath,
  }) async {
    dynamic requestData;

    if (profilePicturePath != null) {
      requestData = FormData.fromMap({
        'fullName': fullName,
        'phone': phone,
        'dateOfBirth': dateOfBirth?.toIso8601String(),
        'gender': gender,
        'address': address,
        'profilePicture': await MultipartFile.fromFile(
          profilePicturePath,
          filename: profilePicturePath.split('/').last,
        ),
      });
    } else {
      requestData = {
        'fullName': fullName,
        'phone': phone,
        'dateOfBirth': dateOfBirth?.toIso8601String(),
        'gender': gender,
        'address': address,
      };
    }

    final response = await apiService.put(
      '/api/Patient/profile',
      data: requestData,
    );
    
    dynamic data = response;
    if (response is Map<String, dynamic>) {
      if (response['success'] == false) {
        throw ApiException(_extractMessage(response));
      }
      data = response.containsKey('data') ? response['data'] : response;
    }

    if (data is Map<String, dynamic>) {
      return PatientProfileModel.fromJson(data);
    }

    throw const ApiException('Unexpected response payload');
  }

  String _extractMessage(dynamic json) {
    if (json is! Map<String, dynamic>) return 'Request failed';
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

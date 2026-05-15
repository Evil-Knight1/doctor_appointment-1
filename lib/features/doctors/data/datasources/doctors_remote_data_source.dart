import 'package:doctor_appointment/core/errors/exceptions.dart';
import 'package:doctor_appointment/core/services/api_service.dart';
import 'package:doctor_appointment/features/doctors/data/models/availability_model.dart';
import 'package:doctor_appointment/features/doctors/data/models/doctor_api_model.dart';
import 'package:doctor_appointment/features/doctors/data/models/doctors_page_model.dart';

abstract class DoctorsRemoteDataSource {
  Future<DoctorsPageModel> searchDoctors({
    int? specializationId,
    double? minRating,
    String? searchTerm,
    int pageNumber,
    int pageSize,
  });

  Future<List<AvailabilityModel>> getDoctorAvailability(int doctorId);
  Future<DoctorApiModel> getDoctorById(int doctorId);
}

class DoctorsRemoteDataSourceImpl implements DoctorsRemoteDataSource {
  final ApiService apiService;

  DoctorsRemoteDataSourceImpl(this.apiService);

  @override
  Future<DoctorsPageModel> searchDoctors({
    int? specializationId,
    double? minRating,
    String? searchTerm,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    final response = await apiService.get(
      '/api/Doctor/search',
      queryParameters: {
        'SpecializationId': specializationId,
        'MinRating': minRating,
        'SearchTerm': searchTerm,
        'PageNumber': pageNumber,
        'PageSize': pageSize,
      }..removeWhere((key, value) => value == null),
    );

    final success = response['success'] == true;
    if (!success) {
      throw ApiException(_extractMessage(response));
    }

    final data = response['data'];
    if (data is Map<String, dynamic>) {
      return DoctorsPageModel.fromJson(data);
    } else if (data is List) {
      // API returned a flat list instead of a paginated object
      return DoctorsPageModel.fromJson({
        'items': data,
        'pageNumber': pageNumber,
        'pageSize': pageSize,
        'totalCount': data.length,
        'totalPages': 1,
      });
    }

    throw const ApiException('Unexpected response payload');
  }

  @override
  Future<List<AvailabilityModel>> getDoctorAvailability(int doctorId) async {
    final response = await apiService.get('/api/Doctor/$doctorId/availability');

    List<dynamic> rawList;
    if (response is List) {
      rawList = response;
    } else if (response is Map<String, dynamic>) {
      final success = response['success'] == true;
      if (!success) throw ApiException(_extractMessage(response));
      final data = response['data'];
      if (data is List) {
        rawList = data;
      } else {
        throw const ApiException('Unexpected availability payload');
      }
    } else {
      throw const ApiException('Unexpected availability payload');
    }

    return rawList
        .whereType<Map<String, dynamic>>()
        .map(AvailabilityModel.fromJson)
        .where((a) => a.isAvailable)
        .toList();
  }

  @override
  Future<DoctorApiModel> getDoctorById(int doctorId) async {
    final response = await apiService.get('/api/Doctor/$doctorId');
    final data = response is Map<String, dynamic> && response['success'] == true
        ? response['data']
        : response;
    if (data is Map<String, dynamic>) {
      return DoctorApiModel.fromJson(data);
    }
    throw const ApiException('Unexpected doctor payload');
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

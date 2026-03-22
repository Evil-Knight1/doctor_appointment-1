import 'package:doctor_appointment/core/errors/exceptions.dart';
import 'package:doctor_appointment/core/services/api_service.dart';
import 'package:doctor_appointment/features/doctors/data/models/doctors_page_model.dart';

abstract class DoctorsRemoteDataSource {
  Future<DoctorsPageModel> searchDoctors({
    String? specialization,
    double? minRating,
    String? searchTerm,
    int pageNumber,
    int pageSize,
  });
}

class DoctorsRemoteDataSourceImpl implements DoctorsRemoteDataSource {
  final ApiService apiService;

  DoctorsRemoteDataSourceImpl(this.apiService);

  @override
  Future<DoctorsPageModel> searchDoctors({
    String? specialization,
    double? minRating,
    String? searchTerm,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    final response = await apiService.get(
      '/api/Doctor/search',
      queryParameters: {
        'Specialization': specialization,
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

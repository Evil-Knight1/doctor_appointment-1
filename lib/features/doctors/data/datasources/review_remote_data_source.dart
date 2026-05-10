import 'package:doctor_appointment/core/errors/exceptions.dart';
import 'package:doctor_appointment/core/services/api_service.dart';
import 'package:doctor_appointment/features/doctors/data/models/review_model.dart';

abstract class ReviewRemoteDataSource {
  Future<ReviewModel> addReview({
    required int doctorId,
    required int stars,
    required String comment,
  });
  Future<List<ReviewModel>> getDoctorReviews(int doctorId);
}

class ReviewRemoteDataSourceImpl implements ReviewRemoteDataSource {
  final ApiService apiService;

  ReviewRemoteDataSourceImpl(this.apiService);

  @override
  Future<ReviewModel> addReview({
    required int doctorId,
    required int stars,
    required String comment,
  }) async {
    final response = await apiService.post(
      '/api/Review',
      data: {'doctorId': doctorId, 'stars': stars, 'comment': comment},
    );

    dynamic data = response;
    if (response is Map<String, dynamic>) {
      if (response['success'] == false) {
        throw ApiException(_extractMessage(response));
      }
      data = response.containsKey('data') ? response['data'] : response;
    }

    if (data is Map<String, dynamic>) {
      return ReviewModel.fromJson(data);
    }
    throw const ApiException('Unexpected response payload');
  }

  @override
  Future<List<ReviewModel>> getDoctorReviews(int doctorId) async {
    final response = await apiService.get('/api/Review/doctor/$doctorId');

    dynamic data = response;
    if (response is Map<String, dynamic>) {
      if (response['success'] == false) {
        throw ApiException(_extractMessage(response));
      }
      data = response.containsKey('data') ? response['data'] : response;
    }

    final List listData = data is List ? data : [];
    return listData.map((json) => ReviewModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  String _extractMessage(dynamic json) {
    if (json is! Map<String, dynamic>) return 'Operation failed';
    if (json['message'] != null) return json['message'] as String;
    final errors = json['errors'];
    if (errors is List && errors.isNotEmpty) return errors.first.toString();
    return 'Operation failed';
  }
}

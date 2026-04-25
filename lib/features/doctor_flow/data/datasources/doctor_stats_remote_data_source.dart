import 'package:doctor_appointment/core/errors/exceptions.dart';
import 'package:doctor_appointment/core/services/api_service.dart';
import 'package:doctor_appointment/features/doctor_flow/data/models/doctor_stats_model.dart';

abstract class DoctorStatsRemoteDataSource {
  Future<DoctorStatsModel> getDoctorStats();
}

class DoctorStatsRemoteDataSourceImpl implements DoctorStatsRemoteDataSource {
  final ApiService apiService;
  DoctorStatsRemoteDataSourceImpl(this.apiService);

  @override
  Future<DoctorStatsModel> getDoctorStats() async {
    final response = await apiService.get('/api/Doctor/statistics');

    if (response['success'] != true) {
      final msg = response['message'] as String? ?? 'Failed to load statistics';
      throw ApiException(msg);
    }

    final data = response['data'];
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Unexpected statistics payload');
    }

    return DoctorStatsModel.fromJson(data);
  }
}

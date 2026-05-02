import 'package:doctor_appointment/core/errors/exceptions.dart';
import 'package:doctor_appointment/core/services/api_service.dart';
import 'package:doctor_appointment/features/doctor_flow/data/models/doctor_stats_model.dart';
import 'package:doctor_appointment/features/doctors/data/models/doctor_api_model.dart';
import 'package:doctor_appointment/features/appointment/data/models/appointment_model.dart';

abstract class DoctorStatsRemoteDataSource {
  Future<DoctorStatsModel> getDoctorStats();
  Future<DoctorApiModel> getDoctorProfile();
  Future<List<AppointmentModel>> getDoctorAppointments();
}

class DoctorStatsRemoteDataSourceImpl implements DoctorStatsRemoteDataSource {
  final ApiService apiService;
  DoctorStatsRemoteDataSourceImpl(this.apiService);

  @override
  Future<DoctorStatsModel> getDoctorStats() async {
    final response = await apiService.get('/api/Doctor/statistics/dashboard');

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

  @override
  Future<DoctorApiModel> getDoctorProfile() async {
    final response = await apiService.get('/api/Doctor/profile');
    if (response['success'] != true) {
      throw ApiException(response['message'] ?? 'Failed to load profile');
    }
    return DoctorApiModel.fromJson(response['data']);
  }

  @override
  Future<List<AppointmentModel>> getDoctorAppointments() async {
    final response = await apiService.get('/api/Doctor/appointments');
    if (response['success'] != true) {
      throw ApiException(response['message'] ?? 'Failed to load appointments');
    }
    final List data = response['data'] ?? [];
    return data.map((e) => AppointmentModel.fromJson(e)).toList();
  }
}

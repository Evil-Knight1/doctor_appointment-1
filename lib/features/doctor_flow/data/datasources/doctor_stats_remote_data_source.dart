import 'package:doctor_appointment/core/errors/exceptions.dart';
import 'package:doctor_appointment/core/services/api_service.dart';
import 'package:doctor_appointment/features/doctor_flow/data/models/doctor_stats_model.dart';
import 'package:doctor_appointment/features/doctors/data/models/doctor_api_model.dart';
import 'package:doctor_appointment/features/appointment/data/models/appointment_model.dart';
import 'package:doctor_appointment/features/doctor_flow/data/models/doctor_monthly_revenue_model.dart';
import 'package:doctor_appointment/features/doctor_flow/data/models/doctor_daily_revenue_model.dart';
import 'package:doctor_appointment/features/doctors/data/models/availability_model.dart';

abstract class DoctorStatsRemoteDataSource {
  Future<DoctorStatsModel> getDoctorStats();
  Future<DoctorApiModel> getDoctorProfile();
  Future<List<AppointmentModel>> getDoctorAppointments();
  Future<DoctorApiModel> updateDoctorProfile(Map<String, dynamic> data);
  Future<AppointmentModel> updateAppointmentStatus(int appointmentId, int status, {String? notes});
  Future<List<DoctorMonthlyRevenueModel>> getMonthlyRevenue(int year);
  Future<List<DoctorDailyRevenueModel>> getDailyRevenue(int year, int month);
  Future<List<AvailabilityModel>> getDoctorAvailability(int doctorId);
  Future<AvailabilityModel> addAvailability(Map<String, dynamic> data);
  Future<AvailabilityModel> updateAvailability(int availabilityId, Map<String, dynamic> data);
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
    final response = await apiService.get('/api/Appointment/doctor/my-appointments');
    if (response['success'] != true) {
      throw ApiException(response['message'] ?? 'Failed to load appointments');
    }
    final List data = response['data'] ?? [];
    return data.map((e) => AppointmentModel.fromJson(e)).toList();
  }

  @override
  Future<DoctorApiModel> updateDoctorProfile(Map<String, dynamic> data) async {
    final response = await apiService.put('/api/Doctor/profile', data: data);
    if (response['success'] != true) {
      throw ApiException(response['message'] ?? 'Failed to update profile');
    }
    return DoctorApiModel.fromJson(response['data']);
  }

  @override
  Future<AppointmentModel> updateAppointmentStatus(int appointmentId, int status, {String? notes}) async {
    final response = await apiService.put(
      '/api/Appointment/$appointmentId/status',
      data: {
        'status': status,
        'doctorNotes': notes,
      },
    );
    if (response['success'] != true) {
      throw ApiException(response['message'] ?? 'Failed to update appointment status');
    }
    return AppointmentModel.fromJson(response['data']);
  }

  @override
  Future<List<DoctorMonthlyRevenueModel>> getMonthlyRevenue(int year) async {
    final response = await apiService.get(
      '/api/Doctor/statistics/monthly-revenue',
      queryParameters: {'year': year},
    );
    if (response['success'] != true) {
      throw ApiException(response['message'] ?? 'Failed to load monthly revenue');
    }
    final List data = response['data'] ?? [];
    return data.map((e) => DoctorMonthlyRevenueModel.fromJson(e)).toList();
  }

  @override
  Future<List<DoctorDailyRevenueModel>> getDailyRevenue(int year, int month) async {
    final response = await apiService.get(
      '/api/Doctor/statistics/daily-revenue',
      queryParameters: {'year': year, 'month': month},
    );
    if (response['success'] != true) {
      throw ApiException(response['message'] ?? 'Failed to load daily revenue');
    }
    final List data = response['data'] ?? [];
    return data.map((e) => DoctorDailyRevenueModel.fromJson(e)).toList();
  }

  @override
  Future<AvailabilityModel> addAvailability(Map<String, dynamic> data) async {
    final response = await apiService.post('/api/Doctor/availability', data: data);
    if (response['success'] != true) {
      throw ApiException(response['message'] ?? 'Failed to add availability');
    }
    return AvailabilityModel.fromJson(response['data']);
  }

  @override
  Future<AvailabilityModel> updateAvailability(int availabilityId, Map<String, dynamic> data) async {
    final response = await apiService.put('/api/Doctor/availability/$availabilityId', data: data);
    if (response['success'] != true) {
      throw ApiException(response['message'] ?? 'Failed to update availability');
    }
    return AvailabilityModel.fromJson(response['data']);
  }

  @override
  Future<List<AvailabilityModel>> getDoctorAvailability(int doctorId) async {
    final response = await apiService.get('/api/Doctor/$doctorId/availability');
    if (response['success'] != true) {
      throw ApiException(response['message'] ?? 'Failed to load availability');
    }
    final List data = response['data'] ?? [];
    return data.map((e) => AvailabilityModel.fromJson(e)).toList();
  }
}

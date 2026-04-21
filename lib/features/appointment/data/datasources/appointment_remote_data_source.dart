import 'package:doctor_appointment/core/errors/exceptions.dart';
import 'package:doctor_appointment/core/services/api_service.dart';
import 'package:doctor_appointment/features/appointment/data/models/appointment_model.dart';

abstract class AppointmentRemoteDataSource {
  Future<AppointmentModel> createAppointment({
    required int doctorId,
    required DateTime startTime,
    required DateTime endTime,
    required String reason,
    int? paymentMethod,
    double? amount,
  });

  Future<List<AppointmentModel>> getMyAppointments();
}

class AppointmentRemoteDataSourceImpl implements AppointmentRemoteDataSource {
  final ApiService apiService;

  AppointmentRemoteDataSourceImpl(this.apiService);

  @override
  Future<AppointmentModel> createAppointment({
    required int doctorId,
    required DateTime startTime,
    required DateTime endTime,
    required String reason,
    int? paymentMethod,
    double? amount,
  }) async {
    final response = await apiService.post(
      '/api/Appointment',
      data: {
        'doctorId': doctorId,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'reason': reason,
        'paymentMethod': paymentMethod,
        'amount': amount,
      },
    );

    final success = response['success'] == true;
    if (!success) {
      throw ApiException(_extractMessage(response));
    }

    final data = response['data'];
    if (data is Map<String, dynamic>) {
      return AppointmentModel.fromJson(data);
    }

    throw const ApiException('Unexpected response payload');
  }

  @override
  Future<List<AppointmentModel>> getMyAppointments() async {
    final response = await apiService.get(
      '/api/Appointment/patient/my-appointments',
    );
    final success = response['success'] == true;
    if (!success) {
      throw ApiException(_extractMessage(response));
    }

    final data = response['data'];
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(AppointmentModel.fromJson)
          .toList();
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

import 'package:doctor_appointment/core/errors/exceptions.dart';
import 'package:doctor_appointment/core/services/api_service.dart';
import 'package:doctor_appointment/features/appointment/data/models/appointment_model.dart';
import 'package:doctor_appointment/features/appointment/data/models/slot_model.dart';
import 'package:intl/intl.dart';

abstract class AppointmentRemoteDataSource {
  Future<AppointmentModel> createAppointment({
    required int doctorId,
    required int slotId,
    required String reason,
    int? paymentMethod,
    double? amount,
    int? type,
  });

  Future<List<AppointmentModel>> getMyAppointments();

  Future<List<SlotModel>> getDoctorSlots(int doctorId, DateTime date);
  Future<void> cancelAppointment(int appointmentId);
}

class AppointmentRemoteDataSourceImpl implements AppointmentRemoteDataSource {
  final ApiService apiService;

  AppointmentRemoteDataSourceImpl(this.apiService);

  @override
  Future<AppointmentModel> createAppointment({
    required int doctorId,
    required int slotId,
    required String reason,
    int? paymentMethod,
    double? amount,
    int? type,
  }) async {
    final body = {
      'doctorId': doctorId,
      'slotId': slotId,
      'reason': reason,
      'paymentMethod': paymentMethod,
      // Send as whole number — backend may reject float for currency
      'amount': amount?.round(),
      'type': type ?? 0,
    };

    final response = await apiService.post('/api/Appointment', data: body);

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

  @override
  Future<List<SlotModel>> getDoctorSlots(int doctorId, DateTime date) async {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final response = await apiService.get(
      '/api/Appointment/slots/$doctorId',
      queryParameters: {'date': dateStr},
    );

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
        throw const ApiException('Unexpected slots payload');
      }
    } else {
      throw const ApiException('Unexpected slots payload');
    }

    return rawList
        .whereType<Map<String, dynamic>>()
        .map(SlotModel.fromJson)
        .toList();
  }

  @override
  Future<void> cancelAppointment(int appointmentId) async {
    final response = await apiService.post('/api/Appointment/$appointmentId/cancel');
    final success = response['success'] == true;
    if (!success) {
      throw ApiException(_extractMessage(response));
    }
  }

  String _extractMessage(Map<String, dynamic> json) {
    final message = json['message'] as String?;
    if (message != null && message.trim().isNotEmpty) {
      return message;
    }
    final errors = json['errors'];
    if (errors is List && errors.isNotEmpty) {
      return errors.map((e) => e.toString()).join(', ');
    } else if (errors is Map) {
      return errors.values
          .map((e) {
            if (e is List) return e.join(', ');
            return e.toString();
          })
          .join(' | ');
    }
    return 'Request failed';
  }
}

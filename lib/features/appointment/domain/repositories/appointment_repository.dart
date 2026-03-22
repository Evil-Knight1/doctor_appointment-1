import 'package:doctor_appointment/core/utils/result.dart';
import 'package:doctor_appointment/features/appointment/domain/entities/appointment.dart';

abstract class AppointmentRepository {
  Future<Result<Appointment>> createAppointment({
    required int doctorId,
    required DateTime startTime,
    required DateTime endTime,
    required String reason,
    int? paymentMethod,
    double? amount,
  });
}

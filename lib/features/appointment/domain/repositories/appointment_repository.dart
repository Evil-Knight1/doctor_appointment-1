import 'package:doctor_appointment/core/utils/result.dart';
import 'package:doctor_appointment/features/appointment/domain/entities/appointment.dart';
import 'package:doctor_appointment/features/appointment/data/models/slot_model.dart';

abstract class AppointmentRepository {
  Future<Result<Appointment>> createAppointment({
    required int doctorId,
    required int slotId,
    required String reason,
    int? paymentMethod,
    double? amount,
    int? type,
  });

  Future<Result<List<Appointment>>> getMyAppointments();
  
  Future<Result<List<SlotModel>>> getDoctorSlots(int doctorId, DateTime date);
  Future<Result<void>> cancelAppointment(int appointmentId);
}

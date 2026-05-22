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
  Future<Result<void>> requestCancel(int appointmentId, String reason);
  Future<Result<void>> requestReschedule(int appointmentId, String reason);
  Future<Result<void>> doctorApproveReschedule(int appointmentId);
  Future<Result<void>> selectRescheduleSlot(int appointmentId, int newSlotId);
  Future<Result<void>> adminCancel(int appointmentId);
}

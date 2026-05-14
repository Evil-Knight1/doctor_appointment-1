import 'package:doctor_appointment/features/home/data/models/home_doctor_model.dart';
import 'package:doctor_appointment/features/appointment/data/models/slot_model.dart';

class AppointmentDraft {
  final HomeDoctorModel doctor;
  final DateTime date;
  final SlotModel slot;
  final String consultationType;
  final double amount;

  const AppointmentDraft({
    required this.doctor,
    required this.date,
    required this.slot,
    required this.consultationType,
    required this.amount,
  });
}

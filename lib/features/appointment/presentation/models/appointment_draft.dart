import 'package:doctor_appointment/features/home/data/models/doctor_model.dart';
import 'package:doctor_appointment/features/appointment/data/models/slot_model.dart';

class AppointmentDraft {
  final DoctorModel doctor;
  final DateTime date;
  final SlotModel slot;
  final String consultationType;

  const AppointmentDraft({
    required this.doctor,
    required this.date,
    required this.slot,
    required this.consultationType,
  });
}

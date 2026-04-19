import 'package:doctor_appointment/features/home/data/models/doctor_model.dart';

class AppointmentDraft {
  final DoctorModel doctor;
  final DateTime date;
  final String time;
  final String consultationType;

  const AppointmentDraft({
    required this.doctor,
    required this.date,
    required this.time,
    required this.consultationType,
  });
}

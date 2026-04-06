import 'package:doctor_appointment/features/appointment/domain/entities/appointment.dart';

sealed class AppointmentState {
  const AppointmentState();
}

class AppointmentInitial extends AppointmentState {
  const AppointmentInitial();
}

class AppointmentLoading extends AppointmentState {
  const AppointmentLoading();
}

class AppointmentSuccess extends AppointmentState {
  final Appointment appointment;

  const AppointmentSuccess(this.appointment);
}

class AppointmentFailure extends AppointmentState {
  final String message;

  const AppointmentFailure(this.message);
}

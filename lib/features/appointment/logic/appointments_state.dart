import 'package:doctor_appointment/features/appointment/domain/entities/appointment.dart';

sealed class AppointmentsState {
  const AppointmentsState();
}

class AppointmentsInitial extends AppointmentsState {
  const AppointmentsInitial();
}

class AppointmentsLoading extends AppointmentsState {
  const AppointmentsLoading();
}

class AppointmentsSuccess extends AppointmentsState {
  final List<Appointment> appointments;

  const AppointmentsSuccess(this.appointments);
}

class AppointmentsFailure extends AppointmentsState {
  final String message;

  const AppointmentsFailure(this.message);
}

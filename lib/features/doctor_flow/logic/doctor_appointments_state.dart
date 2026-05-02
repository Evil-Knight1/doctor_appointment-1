import 'package:doctor_appointment/features/appointment/domain/entities/appointment.dart';
import 'package:equatable/equatable.dart';

abstract class DoctorAppointmentsState extends Equatable {
  const DoctorAppointmentsState();

  @override
  List<Object?> get props => [];
}

class DoctorAppointmentsInitial extends DoctorAppointmentsState {}

class DoctorAppointmentsLoading extends DoctorAppointmentsState {}

class DoctorAppointmentsSuccess extends DoctorAppointmentsState {
  final List<Appointment> appointments;
  const DoctorAppointmentsSuccess(this.appointments);

  @override
  List<Object?> get props => [appointments];
}

class DoctorAppointmentsFailure extends DoctorAppointmentsState {
  final String message;
  const DoctorAppointmentsFailure(this.message);

  @override
  List<Object?> get props => [message];
}

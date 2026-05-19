import 'package:equatable/equatable.dart';
import 'package:doctor_appointment/features/doctors/data/models/availability_model.dart';

abstract class DoctorAvailabilityState extends Equatable {
  const DoctorAvailabilityState();

  @override
  List<Object?> get props => [];
}

class DoctorAvailabilityInitial extends DoctorAvailabilityState {}

class DoctorAvailabilityLoading extends DoctorAvailabilityState {}

class DoctorAvailabilitySuccess extends DoctorAvailabilityState {
  final List<AvailabilityModel> availabilities;
  const DoctorAvailabilitySuccess(this.availabilities);

  @override
  List<Object?> get props => [availabilities];
}

class DoctorAvailabilityFailure extends DoctorAvailabilityState {
  final String message;
  const DoctorAvailabilityFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class DoctorAvailabilitySubmitLoading extends DoctorAvailabilityState {}

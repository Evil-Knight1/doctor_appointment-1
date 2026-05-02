import 'package:doctor_appointment/features/doctors/domain/entities/doctor.dart';
import 'package:equatable/equatable.dart';

abstract class DoctorProfileState extends Equatable {
  const DoctorProfileState();

  @override
  List<Object?> get props => [];
}

class DoctorProfileInitial extends DoctorProfileState {}

class DoctorProfileLoading extends DoctorProfileState {}

class DoctorProfileSuccess extends DoctorProfileState {
  final Doctor doctor;
  const DoctorProfileSuccess(this.doctor);

  @override
  List<Object?> get props => [doctor];
}

class DoctorProfileFailure extends DoctorProfileState {
  final String message;
  const DoctorProfileFailure(this.message);

  @override
  List<Object?> get props => [message];
}

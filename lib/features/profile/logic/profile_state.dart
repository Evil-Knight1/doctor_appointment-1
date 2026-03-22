import 'package:doctor_appointment/features/profile/domain/entities/patient_profile.dart';

sealed class ProfileState {
  const ProfileState();
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileSuccess extends ProfileState {
  final PatientProfile profile;

  const ProfileSuccess(this.profile);
}

class ProfileFailure extends ProfileState {
  final String message;

  const ProfileFailure(this.message);
}

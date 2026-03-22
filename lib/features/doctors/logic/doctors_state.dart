import 'package:doctor_appointment/features/doctors/domain/entities/doctor.dart';

sealed class DoctorsState {
  const DoctorsState();
}

class DoctorsInitial extends DoctorsState {
  const DoctorsInitial();
}

class DoctorsLoading extends DoctorsState {
  const DoctorsLoading();
}

class DoctorsSuccess extends DoctorsState {
  final List<Doctor> doctors;

  const DoctorsSuccess(this.doctors);
}

class DoctorsFailure extends DoctorsState {
  final String message;

  const DoctorsFailure(this.message);
}

import 'package:doctor_appointment/features/doctors/domain/entities/doctors_page.dart';

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
  final DoctorsPage page;

  const DoctorsSuccess(this.page);
}

class DoctorsFailure extends DoctorsState {
  final String message;

  const DoctorsFailure(this.message);
}

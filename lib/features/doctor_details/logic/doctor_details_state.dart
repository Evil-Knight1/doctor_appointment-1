abstract class DoctorDetailsState {
  const DoctorDetailsState();
}

class DoctorDetailsInitial extends DoctorDetailsState {
  const DoctorDetailsInitial();
}

class DoctorDetailsLoading extends DoctorDetailsState {
  const DoctorDetailsLoading();
}

class DoctorDetailsLoaded extends DoctorDetailsState {
  final dynamic doctor;
  final List<String> availableSlots;

  const DoctorDetailsLoaded({
    required this.doctor,
    required this.availableSlots,
  });
}

class DoctorDetailsError extends DoctorDetailsState {
  final String message;

  const DoctorDetailsError(this.message);
}

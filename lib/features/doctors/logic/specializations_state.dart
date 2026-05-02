import 'package:doctor_appointment/features/doctors/domain/entities/specialization.dart';

sealed class SpecializationsState {
  const SpecializationsState();
}

class SpecializationsInitial extends SpecializationsState {
  const SpecializationsInitial();
}

class SpecializationsLoading extends SpecializationsState {
  const SpecializationsLoading();
}

class SpecializationsSuccess extends SpecializationsState {
  final List<Specialization> specializations;
  final Set<String> uniqueNames;

  const SpecializationsSuccess(this.specializations, this.uniqueNames);
}

class SpecializationsFailure extends SpecializationsState {
  final String message;

  const SpecializationsFailure(this.message);
}

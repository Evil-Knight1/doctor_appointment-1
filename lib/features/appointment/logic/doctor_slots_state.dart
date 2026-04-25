import 'package:equatable/equatable.dart';
import 'package:doctor_appointment/features/appointment/data/models/slot_model.dart';

abstract class DoctorSlotsState extends Equatable {
  const DoctorSlotsState();

  @override
  List<Object> get props => [];
}

class DoctorSlotsInitial extends DoctorSlotsState {
  const DoctorSlotsInitial();
}

class DoctorSlotsLoading extends DoctorSlotsState {
  const DoctorSlotsLoading();
}

class DoctorSlotsLoaded extends DoctorSlotsState {
  final List<SlotModel> slots;

  const DoctorSlotsLoaded(this.slots);

  @override
  List<Object> get props => [slots];
}

class DoctorSlotsError extends DoctorSlotsState {
  final String message;

  const DoctorSlotsError(this.message);

  @override
  List<Object> get props => [message];
}

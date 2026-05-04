import 'package:equatable/equatable.dart';

abstract class DoctorDetailsState extends Equatable {
  const DoctorDetailsState();

  @override
  List<Object?> get props => [];
}

class DoctorDetailsInitial extends DoctorDetailsState {}

class DoctorDetailsLoading extends DoctorDetailsState {}

class DoctorDetailsLoaded extends DoctorDetailsState {
  final List<Map<String, dynamic>> reviews;

  const DoctorDetailsLoaded({required this.reviews});

  @override
  List<Object?> get props => [reviews];
}

class DoctorDetailsError extends DoctorDetailsState {
  final String message;

  const DoctorDetailsError(this.message);

  @override
  List<Object?> get props => [message];
}

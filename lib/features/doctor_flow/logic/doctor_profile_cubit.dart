import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doctor_appointment/core/utils/result.dart';
import 'package:doctor_appointment/features/doctor_flow/domain/usecases/get_doctor_profile_usecase.dart';
import 'package:doctor_appointment/features/doctor_flow/logic/doctor_profile_state.dart';

class DoctorProfileCubit extends Cubit<DoctorProfileState> {
  final GetDoctorProfileUseCase getDoctorProfileUseCase;

  DoctorProfileCubit({required this.getDoctorProfileUseCase})
      : super(DoctorProfileInitial());

  Future<void> fetchProfile() async {
    emit(DoctorProfileLoading());
    final result = await getDoctorProfileUseCase();
    
    switch (result) {
      case Success():
        emit(DoctorProfileSuccess(result.data));
      case FailureResult():
        emit(DoctorProfileFailure(result.failure.message));
    }
  }
}

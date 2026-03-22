import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doctor_appointment/core/utils/result.dart';
import 'package:doctor_appointment/features/profile/domain/usecases/get_patient_profile_usecase.dart';
import 'package:doctor_appointment/features/profile/logic/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final GetPatientProfileUseCase getPatientProfileUseCase;

  ProfileCubit({required this.getPatientProfileUseCase})
      : super(const ProfileInitial());

  Future<void> loadProfile() async {
    emit(const ProfileLoading());
    final result = await getPatientProfileUseCase();

    switch (result) {
      case Success():
        emit(ProfileSuccess(result.data));
      case FailureResult():
        emit(ProfileFailure(result.failure.message));
    }
  }
}

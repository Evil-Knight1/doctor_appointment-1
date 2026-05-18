import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:doctor_appointment/core/utils/image_url_helper.dart';
import 'package:doctor_appointment/core/utils/result.dart';
import 'package:doctor_appointment/core/services/app_cache_service.dart';
import 'package:doctor_appointment/features/profile/data/models/patient_profile_model.dart';
import 'package:doctor_appointment/features/profile/domain/usecases/get_patient_profile_usecase.dart';
import 'package:doctor_appointment/features/profile/domain/usecases/update_patient_profile_usecase.dart';
import 'package:doctor_appointment/features/profile/logic/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final GetPatientProfileUseCase getPatientProfileUseCase;
  final UpdatePatientProfileUseCase updatePatientProfileUseCase;
  final AppCacheService appCacheService;

  ProfileCubit({
    required this.getPatientProfileUseCase,
    required this.updatePatientProfileUseCase,
    required this.appCacheService,
  }) : super(const ProfileInitial());

  Future<void> loadProfile() async {
    emit(const ProfileLoading());
    
    final cachedProfile = appCacheService.getCachedProfile();
    if (cachedProfile != null) {
      emit(ProfileSuccess(cachedProfile));
    }

    final result = await getPatientProfileUseCase();

    switch (result) {
      case Success():
        await appCacheService.cacheProfile(result.data as PatientProfileModel);
        emit(ProfileSuccess(result.data));
      case FailureResult():
        if (cachedProfile == null) {
          emit(ProfileFailure(result.failure.message));
        }
    }
  }

  Future<void> updateProfile({
    required String fullName,
    required String phone,
    DateTime? dateOfBirth,
    String? gender,
    String? address,
    String? profilePicturePath,
  }) async {
    emit(const ProfileLoading());
    final result = await updatePatientProfileUseCase(
      UpdatePatientProfileParams(
        fullName: fullName,
        phone: phone,
        dateOfBirth: dateOfBirth,
        gender: gender,
        address: address,
        profilePicturePath: profilePicturePath,
      ),
    );

    switch (result) {
      case Success():
        if (result.data.profilePicture != null) {
          await CachedNetworkImage.evictFromCache(ImageUrlHelper.getFullUrl(result.data.profilePicture));
        }
        await appCacheService.cacheProfile(result.data as PatientProfileModel);
        emit(ProfileSuccess(result.data));
      case FailureResult():
        emit(ProfileFailure(result.failure.message));
    }
  }
}

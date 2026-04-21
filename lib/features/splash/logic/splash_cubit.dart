import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doctor_appointment/core/security/app_permissions.dart';
import 'package:doctor_appointment/features/auth/domain/usecases/get_cached_session_usecase.dart';
import 'package:doctor_appointment/features/splash/logic/splash_state.dart';

import 'package:doctor_appointment/core/utils/result.dart';

class SplashCubit extends Cubit<SplashState> {
  final GetCachedSessionUseCase getCachedSessionUseCase;
  final AppPermissions appPermissions;

  SplashCubit({
    required this.getCachedSessionUseCase,
    required this.appPermissions,
  }) : super(const SplashInitial());

  Future<void> initSplash() async {
    emit(const SplashLoading());
    // Simulate short delay for splash screen animations
    await Future.delayed(const Duration(seconds: 2));

    final result = await getCachedSessionUseCase();

    switch (result) {
      case Success():
        final session = result.data;
        if (session != null) {
          if (session.role == 'patient') {
            appPermissions.updateRole(AppRole.patient);
          }
          emit(const SplashNavigateToHome());
        } else {
          appPermissions.updateRole(AppRole.guest);
          emit(const SplashNavigateToOnboarding());
        }
      case FailureResult():
        appPermissions.updateRole(AppRole.guest);
        emit(const SplashNavigateToOnboarding());
    }
  }
}

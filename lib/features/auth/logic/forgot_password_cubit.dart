import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doctor_appointment/core/errors/failures.dart';
import 'package:doctor_appointment/core/utils/result.dart';
import 'package:doctor_appointment/features/auth/domain/repositories/auth_repository.dart';
import 'package:doctor_appointment/features/auth/logic/forgot_password_state.dart';

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  final AuthRepository authRepository;

  ForgotPasswordCubit({required this.authRepository})
      : super(const ForgotPasswordInitial());

  Future<void> forgotPassword(String email) async {
    emit(const ForgotPasswordLoading());
    final result = await authRepository.forgotPassword(email: email);
    
    switch (result) {
      case Success():
        emit(const ForgotPasswordSuccess('An OTP has been sent to your email.'));
      case FailureResult():
        emit(ForgotPasswordFailure(
          result.failure.message,
          fieldErrors: result.failure is ServerFailure
              ? (result.failure as ServerFailure).fieldErrors
              : {},
        ));
    }
  }

  Future<void> verifyOtp(String email, String otp) async {
    emit(const ForgotPasswordLoading());
    final result = await authRepository.verifyOtp(email: email, otp: otp);
    
    switch (result) {
      case Success():
        emit(OtpVerifiedSuccess(otp));
      case FailureResult():
        emit(ForgotPasswordFailure(
          result.failure.message,
          fieldErrors: result.failure is ServerFailure
              ? (result.failure as ServerFailure).fieldErrors
              : {},
        ));
    }
  }

  Future<void> resetPassword({
    required String email,
    required String token,
    required String newPassword,
  }) async {
    emit(const ForgotPasswordLoading());
    final result = await authRepository.resetPassword(
      email: email,
      token: token,
      newPassword: newPassword,
    );
    
    switch (result) {
      case Success():
        emit(const PasswordResetSuccess());
      case FailureResult():
        emit(ForgotPasswordFailure(
          result.failure.message,
          fieldErrors: result.failure is ServerFailure
              ? (result.failure as ServerFailure).fieldErrors
              : {},
        ));
    }
  }
}

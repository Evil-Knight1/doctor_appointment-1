import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doctor_appointment/core/utils/result.dart';
import 'package:doctor_appointment/features/auth/domain/usecases/login_usecase.dart';
import 'package:doctor_appointment/features/auth/domain/usecases/register_patient_usecase.dart';
import 'package:doctor_appointment/features/auth/logic/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterPatientUseCase registerPatientUseCase;

  AuthCubit({required this.loginUseCase, required this.registerPatientUseCase})
    : super(const AuthInitial());

  Future<void> login({required String email, required String password}) async {
    emit(const AuthLoading());
    final result = await loginUseCase(
      LoginParams(email: email, password: password),
    );

    switch (result) {
      case Success():
        emit(AuthSuccess(result.data));
      case FailureResult():
        emit(AuthFailure(result.failure.message));
    }
  }

  Future<void> registerPatient({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    DateTime? dateOfBirth,
    String? gender,
    String? address,
  }) async {
    emit(const AuthLoading());
    final result = await registerPatientUseCase(
      RegisterPatientParams(
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
        dateOfBirth: dateOfBirth,
        gender: gender,
        address: address,
      ),
    );

    switch (result) {
      case Success():
        emit(AuthSuccess(result.data));
      case FailureResult():
        emit(AuthFailure(result.failure.message));
    }
  }
}

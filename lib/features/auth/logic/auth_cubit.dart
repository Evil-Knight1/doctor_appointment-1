import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doctor_appointment/core/utils/result.dart';
import 'package:doctor_appointment/core/services/shared_preferences_helper.dart';
import 'dart:convert';
import 'package:doctor_appointment/features/auth/domain/entities/auth_response.dart';
import 'package:doctor_appointment/features/auth/domain/usecases/login_usecase.dart';
import 'package:doctor_appointment/features/auth/domain/usecases/register_patient_usecase.dart';
import 'package:doctor_appointment/features/auth/logic/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterPatientUseCase registerPatientUseCase;

  AuthCubit({
    required this.loginUseCase,
    required this.registerPatientUseCase,
  }) : super(const AuthInitial());

  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(const AuthLoading());
    final result = await loginUseCase(
      LoginParams(email: email, password: password),
    );

    switch (result) {
      case Success():
        await _saveUserData(result.data);
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
        await _saveUserData(result.data);
        emit(AuthSuccess(result.data));
      case FailureResult():
        emit(AuthFailure(result.failure.message));
    }
  }

  Future<void> _saveUserData(AuthResponse data) async {
    await SharedPreferencesHelper.saveToken(data.token);
    final userJson = {
      'token': data.token,
      'refreshToken': data.refreshToken,
      'email': data.email,
      'role': data.role,
      'userId': data.userId,
      'expiresAt': data.expiresAt.toIso8601String(),
    };
    await SharedPreferencesHelper.saveUserData(jsonEncode(userJson));
  }
}

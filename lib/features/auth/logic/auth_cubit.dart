import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doctor_appointment/core/errors/failures.dart';
import 'package:doctor_appointment/core/utils/result.dart';
import 'package:doctor_appointment/core/services/shared_preferences_helper.dart';
import 'dart:convert';
import 'package:doctor_appointment/features/auth/domain/entities/auth_response.dart';
import 'package:doctor_appointment/features/auth/domain/usecases/login_usecase.dart';
import 'package:doctor_appointment/features/auth/domain/usecases/register_patient_usecase.dart';
import 'package:doctor_appointment/features/auth/domain/usecases/register_doctor_usecase.dart';
import 'package:doctor_appointment/features/auth/logic/auth_state.dart';
import 'package:doctor_appointment/features/auth/domain/usecases/update_fcm_token_usecase.dart';
import 'package:doctor_appointment/core/services/notification_service.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterPatientUseCase registerPatientUseCase;
  final RegisterDoctorUseCase registerDoctorUseCase;
  final UpdateFcmTokenUseCase updateFcmTokenUseCase;

  AuthCubit({
    required this.loginUseCase,
    required this.registerPatientUseCase,
    required this.registerDoctorUseCase,
    required this.updateFcmTokenUseCase,
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
        await _updateFcmToken();
        emit(AuthSuccess(result.data, role: _normalizeRole(result.data.role)));
      case FailureResult():
        emit(AuthFailure(
          result.failure.message,
          fieldErrors: result.failure is ServerFailure
              ? (result.failure as ServerFailure).fieldErrors
              : {},
        ));
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
    String? profilePicturePath,
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
        profilePicturePath: profilePicturePath,
      ),
    );

    switch (result) {
      case Success():
        await _saveUserData(result.data);
        await _updateFcmToken();
        emit(AuthSuccess(result.data, role: _normalizeRole(result.data.role)));
      case FailureResult():
        emit(AuthFailure(
          result.failure.message,
          fieldErrors: result.failure is ServerFailure
              ? (result.failure as ServerFailure).fieldErrors
              : {},
        ));
    }
  }

  Future<void> registerDoctor({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required int specializationId,
    required int experienceYears,
    required String licenseId,
    required String clinicAddress,
    required String hospitalName,
    DateTime? dateOfBirth,
    String? gender,
    String? bio,
    String? profilePicturePath,
    List<String>? clinicImagesPaths,
  }) async {
    emit(const AuthLoading());
    final result = await registerDoctorUseCase(
      RegisterDoctorParams(
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
        specializationId: specializationId,
        experienceYears: experienceYears,
        licenseId: licenseId,
        clinicAddress: clinicAddress,
        hospitalName: hospitalName,
        dateOfBirth: dateOfBirth,
        gender: gender,
        bio: bio,
        profilePicturePath: profilePicturePath,
        clinicImagesPaths: clinicImagesPaths,
      ),
    );

    switch (result) {
      case Success():
        await _saveUserData(result.data);
        await _updateFcmToken();
        emit(AuthSuccess(result.data, role: _normalizeRole(result.data.role)));
      case FailureResult():
        emit(AuthFailure(
          result.failure.message,
          fieldErrors: result.failure is ServerFailure
              ? (result.failure as ServerFailure).fieldErrors
              : {},
        ));
    }
  }

  Future<void> _saveUserData(AuthResponse data) async {
    final normalizedRole = _normalizeRole(data.role);
    await SharedPreferencesHelper.saveToken(data.token);
    final userJson = {
      'token': data.token,
      'refreshToken': data.refreshToken,
      'email': data.email,
      'role': normalizedRole,
      'userId': data.userId,
      'expiresAt': data.expiresAt.toIso8601String(),
    };
    await SharedPreferencesHelper.saveUserData(jsonEncode(userJson));
  }

  String _normalizeRole(String? role) {
    final value = role?.trim().toLowerCase() ?? '';
    return value == 'doctor' ? 'doctor' : 'patient';
  }

  Future<void> _updateFcmToken() async {
    final fcmToken = await NotificationService().getFcmToken();
    if (fcmToken != null) {
      await updateFcmTokenUseCase(fcmToken);
    }
  }
}

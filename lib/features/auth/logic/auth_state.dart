import 'package:doctor_appointment/features/auth/domain/entities/auth_response.dart';
import 'package:doctor_appointment/core/utils/go_router.dart';

sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthSuccess extends AuthState {
  final AuthResponse response;
  final String role;

  const AuthSuccess(this.response, {required this.role});

  bool get isDoctor => role == 'doctor';

  String get targetRoute => isDoctor ? AppRouter.kDoctorRoot : AppRouter.kRoot;
}

class AuthFailure extends AuthState {
  final String message;
  /// Per-field validation errors from the server (e.g. 'password', 'phone').
  final Map<String, String> fieldErrors;

  const AuthFailure(this.message, {this.fieldErrors = const {}});
}


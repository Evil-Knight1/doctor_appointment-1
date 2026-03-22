import 'package:doctor_appointment/features/auth/domain/entities/auth_response.dart';

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

  const AuthSuccess(this.response);
}

class AuthFailure extends AuthState {
  final String message;

  const AuthFailure(this.message);
}

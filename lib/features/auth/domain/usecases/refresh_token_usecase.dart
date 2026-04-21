import 'package:doctor_appointment/core/utils/result.dart';
import 'package:doctor_appointment/features/auth/domain/entities/auth_response.dart';
import 'package:doctor_appointment/features/auth/domain/repositories/auth_repository.dart';

class RefreshTokenUseCase {
  final AuthRepository repository;

  const RefreshTokenUseCase(this.repository);

  Future<Result<AuthResponse>> call(RefreshTokenParams params) {
    return repository.refreshToken(
      token: params.token,
      refreshToken: params.refreshToken,
    );
  }
}

class RefreshTokenParams {
  final String token;
  final String refreshToken;

  const RefreshTokenParams({required this.token, required this.refreshToken});
}

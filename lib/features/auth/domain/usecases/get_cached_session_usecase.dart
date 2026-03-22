import 'package:doctor_appointment/core/utils/result.dart';
import 'package:doctor_appointment/features/auth/domain/entities/auth_response.dart';
import 'package:doctor_appointment/features/auth/domain/repositories/auth_repository.dart';

class GetCachedSessionUseCase {
  final AuthRepository repository;

  const GetCachedSessionUseCase(this.repository);

  Future<Result<AuthResponse?>> call() {
    return repository.getCachedSession();
  }
}

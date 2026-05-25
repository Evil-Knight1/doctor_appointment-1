import 'package:doctor_appointment/core/utils/result.dart';
import 'package:doctor_appointment/features/auth/data/models/availability_check_model.dart';
import 'package:doctor_appointment/features/auth/domain/repositories/auth_repository.dart';

class CheckAvailabilityUseCase {
  final AuthRepository repository;

  const CheckAvailabilityUseCase(this.repository);

  Future<Result<AvailabilityCheckModel>> call({
    String? email,
    String? phone,
  }) {
    return repository.checkAvailability(email: email, phone: phone);
  }
}

import 'package:doctor_appointment/core/utils/result.dart';
import 'package:doctor_appointment/features/auth/domain/repositories/auth_repository.dart';

class UpdateFcmTokenUseCase {
  final AuthRepository repository;

  UpdateFcmTokenUseCase(this.repository);

  Future<Result<bool>> call(String fcmToken) async {
    return await repository.updateFcmToken(fcmToken: fcmToken);
  }
}

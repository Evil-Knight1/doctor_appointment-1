import 'package:doctor_appointment/core/utils/result.dart';
import 'package:doctor_appointment/features/payments/domain/entities/payment_result.dart';
import 'package:doctor_appointment/features/payments/domain/repositories/payment_repository.dart';

/// Polls the backend for the verified payment status of an appointment.
///
/// Always use backend polling — never trust the client-side WebView callback
/// alone. The webhook from Paymob is the authoritative confirmation signal.
class GetPaymentStatusUseCase {
  final PaymentRepository _repository;

  const GetPaymentStatusUseCase(this._repository);

  Future<Result<PaymentResult>> call(int appointmentId) {
    return _repository.getPaymentStatus(appointmentId: appointmentId);
  }
}

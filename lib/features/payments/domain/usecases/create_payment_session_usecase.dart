import 'package:doctor_appointment/core/utils/result.dart';
import 'package:doctor_appointment/features/payments/domain/entities/payment_session.dart';
import 'package:doctor_appointment/features/payments/domain/repositories/payment_repository.dart';

class CreatePaymentSessionParams {
  final int appointmentId;
  final double amount;
  final String currency;

  /// 1 = Credit/Debit Card, 2 = Mobile Wallet
  final int paymentMethodType;

  const CreatePaymentSessionParams({
    required this.appointmentId,
    required this.amount,
    this.currency = 'EGP',
    required this.paymentMethodType,
  });
}

/// Requests the backend to create a Paymob payment session.
///
/// Returns a [PaymentSession] containing the in-app payment URL.
/// No API secrets are ever passed to or stored in Flutter.
class CreatePaymentSessionUseCase {
  final PaymentRepository _repository;

  const CreatePaymentSessionUseCase(this._repository);

  Future<Result<PaymentSession>> call(CreatePaymentSessionParams params) {
    return _repository.createPaymentSession(
      appointmentId: params.appointmentId,
      amount: params.amount,
      currency: params.currency,
      paymentMethodType: params.paymentMethodType,
    );
  }
}

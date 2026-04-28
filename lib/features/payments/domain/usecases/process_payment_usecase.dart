import 'package:doctor_appointment/core/utils/result.dart';
import 'package:doctor_appointment/features/payments/domain/repositories/payment_repository.dart';

class ProcessPaymentUseCase {
  final PaymentRepository repository;

  const ProcessPaymentUseCase(this.repository);

  Future<Result<String?>> call(ProcessPaymentParams params) {
    return repository.processPayment(
      appointmentId: params.appointmentId,
      amount: params.amount,
      paymentMethod: params.paymentMethod,
      transactionId: params.transactionId,
      paymentDetails: params.paymentDetails,
    );
  }
}

class ProcessPaymentParams {
  final int appointmentId;
  final double amount;
  final int paymentMethod;
  final String? transactionId;
  final String? paymentDetails;

  const ProcessPaymentParams({
    required this.appointmentId,
    required this.amount,
    required this.paymentMethod,
    this.transactionId,
    this.paymentDetails,
  });
}

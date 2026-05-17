import 'package:doctor_appointment/core/utils/result.dart';
import 'package:doctor_appointment/features/payments/domain/entities/payment_result.dart';
import 'package:doctor_appointment/features/payments/domain/entities/payment_session.dart';

/// Defines the payment contract for the domain layer.
///
/// The backend is the single source of truth:
/// - It creates payment intentions with Paymob.
/// - It verifies webhooks from Paymob.
/// - It stores all payment events.
///
/// Flutter only requests a session and reports the in-app UI result;
/// it never touches Paymob API keys directly.
abstract class PaymentRepository {
  /// Asks the backend to create a Paymob payment session for [appointmentId].
  ///
  /// The backend:
  /// 1. Authenticates with Paymob using its secret API key.
  /// 2. Creates a Paymob order.
  /// 3. Generates a payment key.
  /// 4. Builds the iframe URL and stores the session.
  /// 5. Returns only the [PaymentSession] (no secrets) to Flutter.
  Future<Result<PaymentSession>> createPaymentSession({
    required int appointmentId,
    required double amount,
    required String currency,
    required int paymentMethodType, // 1=Card, 2=Wallet
  });

  /// Polls the backend for the verified payment result for [appointmentId].
  ///
  /// The backend confirms status only after Paymob webhook verification.
  /// Retries should be handled at the cubit level with a back-off strategy.
  Future<Result<PaymentResult>> getPaymentStatus({
    required int appointmentId,
  });

  /// Notifies the backend that the user completed or cancelled the in-app flow.
  ///
  /// This is a best-effort call — the webhook is the true confirmation signal.
  /// [providerTransactionId] comes from the WebView success URL params.
  Future<Result<void>> reportPaymentCompletion({
    required int appointmentId,
    required bool success,
    String? providerTransactionId,
    String? failureReason,
  });
}

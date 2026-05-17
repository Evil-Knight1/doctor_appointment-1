import 'package:equatable/equatable.dart';
import 'package:doctor_appointment/features/payments/domain/entities/payment_status.dart';

/// Represents the verified result of a payment, sourced from the backend.
///
/// This is populated by polling GET /api/Payment/status/{appointmentId}
/// after the user completes the Paymob payment flow. The backend verifies
/// this via webhook from Paymob — it is the authoritative source of truth.
class PaymentResult extends Equatable {
  /// Our backend's internal payment record ID.
  final int paymentId;

  /// The appointment this payment belongs to.
  final int appointmentId;

  /// Current payment status from the backend.
  final PaymentStatus status;

  /// Paymob's transaction ID (stored in backend after webhook).
  final String? transactionId;

  /// Paymob's order ID.
  final String? orderId;

  /// Human-readable failure reason (populated on [PaymentStatus.failed]).
  final String? failureReason;

  /// Timestamp when payment was confirmed as paid.
  final DateTime? paidAt;

  /// Amount paid.
  final double amount;

  /// Currency used.
  final String currency;

  const PaymentResult({
    required this.paymentId,
    required this.appointmentId,
    required this.status,
    this.transactionId,
    this.orderId,
    this.failureReason,
    this.paidAt,
    required this.amount,
    required this.currency,
  });

  bool get isSuccess => status == PaymentStatus.paid;
  bool get isFailure => status == PaymentStatus.failed;
  bool get isCancelled => status == PaymentStatus.cancelled;

  @override
  List<Object?> get props => [
        paymentId,
        appointmentId,
        status,
        transactionId,
        orderId,
        failureReason,
        paidAt,
        amount,
        currency,
      ];
}

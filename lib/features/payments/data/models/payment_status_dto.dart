import 'package:doctor_appointment/features/payments/domain/entities/payment_result.dart';
import 'package:doctor_appointment/features/payments/domain/entities/payment_status.dart';

/// DTO: maps the backend response for GET /api/Payment/status/{appointmentId}.
///
/// Backend response shape:
/// ```json
/// {
///   "success": true,
///   "data": {
///     "paymentId": 1,
///     "appointmentId": 42,
///     "status": "paid",
///     "transactionId": "paymob_txn_id",
///     "orderId": "paymob_order_id",
///     "failureReason": null,
///     "paidAt": "2024-01-01T12:05:30Z",
///     "amount": 500.00,
///     "currency": "EGP"
///   }
/// }
/// ```
class PaymentStatusDto {
  final int paymentId;
  final int appointmentId;
  final String statusRaw;
  final String? transactionId;
  final String? orderId;
  final String? failureReason;
  final DateTime? paidAt;
  final double amount;
  final String currency;

  const PaymentStatusDto({
    required this.paymentId,
    required this.appointmentId,
    required this.statusRaw,
    this.transactionId,
    this.orderId,
    this.failureReason,
    this.paidAt,
    required this.amount,
    required this.currency,
  });

  factory PaymentStatusDto.fromJson(Map<String, dynamic> json) {
    return PaymentStatusDto(
      paymentId: json['paymentId'] as int,
      appointmentId: json['appointmentId'] as int,
      statusRaw: json['status'] as String? ?? 'unknown',
      transactionId: json['transactionId'] as String?,
      orderId: json['orderId'] as String?,
      failureReason: json['failureReason'] as String?,
      paidAt: json['paidAt'] != null
          ? DateTime.tryParse(json['paidAt'] as String)
          : null,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'EGP',
    );
  }

  /// Converts this DTO to the domain entity.
  PaymentResult toDomain() => PaymentResult(
        paymentId: paymentId,
        appointmentId: appointmentId,
        status: PaymentStatus.fromString(statusRaw),
        transactionId: transactionId,
        orderId: orderId,
        failureReason: failureReason,
        paidAt: paidAt,
        amount: amount,
        currency: currency,
      );
}

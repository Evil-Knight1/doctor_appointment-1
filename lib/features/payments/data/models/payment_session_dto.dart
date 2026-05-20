import 'package:doctor_appointment/features/payments/domain/entities/payment_session.dart';

/// DTO: maps the backend response for POST /api/Payment/create-session.
///
/// Backend response shape:
/// ```json
/// {
///   "success": true,
///   "data": {
///     "sessionId": "uuid",
///     "appointmentId": 42,
///     "paymentUrl": "https://accept.paymob.com/...",
///     "providerOrderId": "paymob_order_id",
///     "amount": 500.00,
///     "currency": "EGP",
///     "expiresAt": "2024-01-01T12:00:00Z"
///   }
/// }
/// ```
class PaymentSessionDto {
  final String sessionId;
  final int appointmentId;
  final String paymentUrl;
  final String? clientSecret;
  final String? providerOrderId;
  final double amount;
  final String currency;
  final DateTime? expiresAt;

  const PaymentSessionDto({
    required this.sessionId,
    required this.appointmentId,
    required this.paymentUrl,
    this.clientSecret,
    this.providerOrderId,
    required this.amount,
    required this.currency,
    this.expiresAt,
  });

  factory PaymentSessionDto.fromJson(Map<String, dynamic> json) {
    return PaymentSessionDto(
      sessionId: json['sessionId'] as String,
      appointmentId: json['appointmentId'] as int,
      paymentUrl: json['paymentUrl'] as String,
      clientSecret: json['clientSecret'] as String?,
      providerOrderId: json['providerOrderId'] as String?,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'EGP',
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'] as String)
          : null,
    );
  }

  /// Converts this DTO to the domain entity.
  PaymentSession toDomain() => PaymentSession(
        sessionId: sessionId,
        appointmentId: appointmentId,
        paymentUrl: paymentUrl,
        clientSecret: clientSecret,
        providerOrderId: providerOrderId,
        amount: amount,
        currency: currency,
        expiresAt: expiresAt,
      );
}

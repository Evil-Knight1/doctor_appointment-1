import 'package:equatable/equatable.dart';

/// Represents a payment session created by the backend.
///
/// The backend calls Paymob's API and returns only the payment URL
/// (embedding the payment key inside). Flutter never touches API secrets.
class PaymentSession extends Equatable {
  /// Our backend's internal session ID (UUID).
  final String sessionId;

  /// The appointment this payment is for.
  final int appointmentId;

  /// The fully-formed Paymob iframe URL:
  /// `https://accept.paymob.com/api/acceptance/iframes/{iframeId}?payment_token={key}`
  /// Opened inside a WebView — no browser redirect.
  final String paymentUrl;

  /// Paymob's order reference ID (stored by backend, returned for tracing).
  final String? providerOrderId;

  /// Amount in the major currency unit (e.g. 500.00 EGP).
  final double amount;

  /// ISO 4217 currency code (e.g. "EGP").
  final String currency;

  /// When this session expires (Paymob payment keys expire in ~1 hour).
  final DateTime? expiresAt;

  const PaymentSession({
    required this.sessionId,
    required this.appointmentId,
    required this.paymentUrl,
    this.providerOrderId,
    required this.amount,
    required this.currency,
    this.expiresAt,
  });

  bool get isExpired =>
      expiresAt != null && DateTime.now().isAfter(expiresAt!);

  @override
  List<Object?> get props => [
        sessionId,
        appointmentId,
        paymentUrl,
        providerOrderId,
        amount,
        currency,
        expiresAt,
      ];
}

/// Represents the full lifecycle of a payment transaction.
/// Backend is the single source of truth for this status.
enum PaymentStatus {
  /// Payment has been initiated but no action taken yet.
  pending,

  /// User has opened the payment UI; gateway processing in progress.
  processing,

  /// Payment confirmed by Paymob webhook → appointment activated.
  paid,

  /// Payment was declined or an error occurred.
  failed,

  /// User explicitly cancelled the payment.
  cancelled,

  /// Payment was reversed after being confirmed.
  refunded,

  /// Payment session expired before user completed the payment.
  expired,

  /// Status is unknown (e.g. polling timeout before webhook arrives).
  unknown;

  /// Maps a raw backend/provider string to the enum.
  static PaymentStatus fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'pending':
        return PaymentStatus.pending;
      case 'processing':
        return PaymentStatus.processing;
      case 'paid':
      case 'success':
      case 'completed':
        return PaymentStatus.paid;
      case 'failed':
      case 'failure':
        return PaymentStatus.failed;
      case 'cancelled':
      case 'canceled':
        return PaymentStatus.cancelled;
      case 'refunded':
        return PaymentStatus.refunded;
      case 'expired':
        return PaymentStatus.expired;
      default:
        return PaymentStatus.unknown;
    }
  }

  bool get isTerminal =>
      this == PaymentStatus.paid ||
      this == PaymentStatus.failed ||
      this == PaymentStatus.cancelled ||
      this == PaymentStatus.refunded ||
      this == PaymentStatus.expired;
}

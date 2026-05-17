import 'package:equatable/equatable.dart';
import 'package:doctor_appointment/features/payments/domain/entities/payment_result.dart';
import 'package:doctor_appointment/features/payments/domain/entities/payment_session.dart';
import 'package:doctor_appointment/features/payments/domain/entities/payment_status.dart';

/// Base state — always holds [appointmentId] and [amount] for UI access.
abstract class PaymentState extends Equatable {
  final int? appointmentId;
  final double? amount;
  final String currency;

  const PaymentState({
    this.appointmentId,
    this.amount,
    this.currency = 'EGP',
  });

  @override
  List<Object?> get props => [appointmentId, amount, currency];
}

// ─── Idle ──────────────────────────────────────────────────────────────────

/// The cubit is idle; no payment operation has started.
class PaymentInitial extends PaymentState {
  const PaymentInitial() : super();
}

// ─── Loading ───────────────────────────────────────────────────────────────

/// A background operation is in progress (creating session or creating appointment).
class PaymentLoading extends PaymentState {
  /// Human-readable description of what is being loaded.
  final String message;

  const PaymentLoading({
    required this.message,
    super.appointmentId,
    super.amount,
    super.currency,
  });

  @override
  List<Object?> get props => [...super.props, message];
}

// ─── Session Created ───────────────────────────────────────────────────────

/// Backend has created the payment session.
/// The [session] contains the Paymob payment URL to open in a WebView.
class PaymentSessionCreated extends PaymentState {
  final PaymentSession session;

  PaymentSessionCreated({required this.session})
      : super(
          appointmentId: session.appointmentId,
          amount: session.amount,
          currency: session.currency,
        );

  @override
  List<Object?> get props => [...super.props, session];
}

// ─── Processing ────────────────────────────────────────────────────────────

/// The user has submitted the payment in the WebView.
/// We are now polling the backend for webhook confirmation.
class PaymentPendingVerification extends PaymentState {
  /// Number of polling attempts so far.
  final int pollCount;

  const PaymentPendingVerification({
    required super.appointmentId,
    required super.amount,
    super.currency,
    this.pollCount = 0,
  });

  PaymentPendingVerification copyWith({int? pollCount}) =>
      PaymentPendingVerification(
        appointmentId: appointmentId,
        amount: amount,
        currency: currency,
        pollCount: pollCount ?? this.pollCount,
      );

  @override
  List<Object?> get props => [...super.props, pollCount];
}

// ─── Success ───────────────────────────────────────────────────────────────

/// Webhook confirmed. Backend updated appointment to Confirmed.
class PaymentSuccess extends PaymentState {
  final PaymentResult result;

  PaymentSuccess({required this.result})
      : super(
          appointmentId: result.appointmentId,
          amount: result.amount,
          currency: result.currency,
        );

  @override
  List<Object?> get props => [...super.props, result];
}

// ─── Failure ───────────────────────────────────────────────────────────────

/// A payment attempt has failed (network, gateway, or webhook rejection).
class PaymentFailure extends PaymentState {
  final String message;

  /// If set, the user can retry from this known payment status.
  final PaymentStatus? lastKnownStatus;

  const PaymentFailure({
    required this.message,
    this.lastKnownStatus,
    super.appointmentId,
    super.amount,
    super.currency,
  });

  @override
  List<Object?> get props => [...super.props, message, lastKnownStatus];
}

// ─── Cancelled ─────────────────────────────────────────────────────────────

/// The user dismissed the Paymob WebView without completing payment.
class PaymentCancelled extends PaymentState {
  const PaymentCancelled({
    super.appointmentId,
    super.amount,
    super.currency,
  });
}

// ─── Cash Confirmed ────────────────────────────────────────────────────────

/// Appointment was booked with cash-at-clinic. No gateway flow needed.
class PaymentCashConfirmed extends PaymentState {
  const PaymentCashConfirmed({
    required super.appointmentId,
    super.amount,
  });
}

import 'dart:async';

import 'package:doctor_appointment/core/utils/result.dart';
import 'package:doctor_appointment/features/appointment/domain/usecases/create_appointment_usecase.dart';
import 'package:doctor_appointment/features/payments/domain/entities/payment_status.dart';
import 'package:doctor_appointment/features/payments/domain/usecases/create_payment_session_usecase.dart';
import 'package:doctor_appointment/features/payments/domain/usecases/get_payment_status_usecase.dart';
import 'package:doctor_appointment/features/payments/domain/repositories/payment_repository.dart';
import 'package:doctor_appointment/features/payments/logic/payment_state.dart';
import 'package:doctor_appointment/features/payments/data/services/paymob_sdk_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Orchestrates the entire backend-driven payment flow.
///
/// Flow for card / wallet:
/// 1. [checkout] → creates appointment → emits [PaymentLoading]
/// 2.            → calls [CreatePaymentSessionUseCase] → emits [PaymentSessionCreated]
/// 3. UI opens the Paymob WebView with [PaymentSessionCreated.session.paymentUrl]
/// 4. WebView calls [onWebViewResult] on success/cancel
/// 5. [startPolling] → polls backend up to [_maxPollAttempts] times
/// 6.              → emits [PaymentSuccess] or [PaymentFailure]
///
/// Flow for cash-at-clinic:
/// 1. [checkout] → creates appointment → emits [PaymentCashConfirmed]
///
/// The backend webhook is the only authoritative confirmation. Polling is
/// the Flutter-side mechanism to detect when the webhook has been processed.
class PaymentCubit extends Cubit<PaymentState> {
  final CreateAppointmentUseCase _createAppointmentUseCase;
  final CreatePaymentSessionUseCase _createPaymentSessionUseCase;
  final GetPaymentStatusUseCase _getPaymentStatusUseCase;
  final PaymentRepository _paymentRepository;
  final PaymobSdkService _paymobSdkService = PaymobSdkService();

  /// How many times to poll before giving up.
  static const int _maxPollAttempts = 12;

  /// Interval between each poll.
  static const Duration _pollInterval = Duration(seconds: 5);

  Timer? _pollTimer;
  int _pollCount = 0;
  int? _activeAppointmentId;

  PaymentCubit({
    required CreateAppointmentUseCase createAppointmentUseCase,
    required CreatePaymentSessionUseCase createPaymentSessionUseCase,
    required GetPaymentStatusUseCase getPaymentStatusUseCase,
    required PaymentRepository paymentRepository,
  })  : _createAppointmentUseCase = createAppointmentUseCase,
        _createPaymentSessionUseCase = createPaymentSessionUseCase,
        _getPaymentStatusUseCase = getPaymentStatusUseCase,
        _paymentRepository = paymentRepository,
        super(const PaymentInitial());

  // ─── Public API ──────────────────────────────────────────────────────────

  /// Entry point: creates the appointment then either opens a payment session
  /// or confirms a cash booking immediately.
  Future<void> checkout({
    required int doctorId,
    required int slotId,
    required String reason,
    required int paymentMethod, // 1=Card, 2=Wallet, 3=Cash
    required double amount,
    int? type,
  }) async {
    emit(PaymentLoading(message: 'Creating appointment…', amount: amount));

    // ── Step 1: Create Appointment ─────────────────────────────────────────
    final appointmentResult = await _createAppointmentUseCase(
      CreateAppointmentParams(
        doctorId: doctorId,
        slotId: slotId,
        reason: reason,
        paymentMethod: paymentMethod,
        amount: amount,
        type: type,
      ),
    );

    switch (appointmentResult) {
      case FailureResult():
        emit(PaymentFailure(
          message: appointmentResult.failure.message,
          amount: amount,
        ));
        return;

      case Success():
        final appointment = appointmentResult.data;
        _activeAppointmentId = appointment.id;

        // ── Step 2a: Cash at clinic → done immediately ─────────────────────
        if (paymentMethod == 3) {
          emit(PaymentCashConfirmed(appointmentId: appointment.id, amount: amount));
          return;
        }

        // ── Step 2b: Card / Wallet → request a payment session ────────────
        emit(PaymentLoading(
          message: 'Opening payment gateway…',
          appointmentId: appointment.id,
          amount: amount,
        ));

        final sessionResult = await _createPaymentSessionUseCase(
          CreatePaymentSessionParams(
            appointmentId: appointment.id,
            amount: amount,
            paymentMethodType: paymentMethod,
          ),
        );

        switch (sessionResult) {
          case FailureResult():
            emit(PaymentFailure(
              message: sessionResult.failure.message,
              appointmentId: appointment.id,
              amount: amount,
            ));
          case Success():
            final session = sessionResult.data;
            if (session.clientSecret != null && session.clientSecret!.isNotEmpty) {
              // Intention API (Native SDK) route
              final result = await _paymobSdkService.payWithNativeSdk(
                publicKey: 'YOUR_PUBLIC_KEY', // TODO: Get from env/config
                clientSecret: session.clientSecret!,
              );
              
              if (result == 'Successfull') {
                onWebViewResult(success: true);
              } else if (result == 'Pending') {
                onWebViewResult(success: true, failureReason: 'Pending');
              } else {
                onWebViewResult(success: false, failureReason: 'Rejected');
              }
            } else {
              // Fallback to WebView
              emit(PaymentSessionCreated(session: session));
            }
        }
    }
  }

  /// Called by the WebView screen when the Paymob iframe reports a result.
  ///
  /// [success] — whether the WebView detected a success redirect.
  /// [providerTransactionId] — parsed from the success callback URL if available.
  ///
  /// Always starts backend polling regardless of WebView result because
  /// the WebView callback is NOT authoritative — the webhook is.
  Future<void> onWebViewResult({
    required bool success,
    String? providerTransactionId,
    String? failureReason,
  }) async {
    if (_activeAppointmentId == null) return;

    // Best-effort notification to backend (non-blocking, swallowed on error).
    unawaited(_paymentRepository.reportPaymentCompletion(
      appointmentId: _activeAppointmentId!,
      success: success,
      providerTransactionId: providerTransactionId,
      failureReason: failureReason,
    ));

    if (success) {
      // Start polling for webhook confirmation.
      startPolling();
    } else {
      emit(PaymentCancelled(
        appointmentId: _activeAppointmentId,
        amount: state.amount,
      ));
    }
  }

  /// Begins polling the backend for payment status confirmation.
  ///
  /// Emits [PaymentPendingVerification] immediately, then polls every
  /// [_pollInterval] until the status is terminal or [_maxPollAttempts] is hit.
  void startPolling() {
    _stopPolling();
    _pollCount = 0;

    emit(PaymentPendingVerification(
      appointmentId: _activeAppointmentId,
      amount: state.amount,
      currency: state.currency,
    ));

    _pollTimer = Timer.periodic(_pollInterval, (_) => _pollStatus());
  }

  // ─── Private helpers ─────────────────────────────────────────────────────

  Future<void> _pollStatus() async {
    if (_activeAppointmentId == null) {
      _stopPolling();
      return;
    }

    _pollCount++;

    final result = await _getPaymentStatusUseCase(_activeAppointmentId!);

    switch (result) {
      case FailureResult():
        // Transient network error — keep polling unless max attempts reached.
        if (_pollCount >= _maxPollAttempts) {
          _stopPolling();
          emit(PaymentFailure(
            message: 'Could not verify payment. Please check your appointment status.',
            appointmentId: _activeAppointmentId,
            amount: state.amount,
            lastKnownStatus: PaymentStatus.unknown,
          ));
        }

      case Success():
        final paymentResult = result.data;

        if (isClosed) return;

        // Update poll count in the current pending state.
        if (state is PaymentPendingVerification) {
          emit((state as PaymentPendingVerification).copyWith(
            pollCount: _pollCount,
          ));
        }

        if (paymentResult.status.isTerminal) {
          _stopPolling();

          if (paymentResult.status == PaymentStatus.paid) {
            emit(PaymentSuccess(result: paymentResult));
          } else {
            emit(PaymentFailure(
              message: paymentResult.failureReason ??
                  'Payment ${paymentResult.status.name}.',
              appointmentId: _activeAppointmentId,
              amount: paymentResult.amount,
              lastKnownStatus: paymentResult.status,
            ));
          }
        } else if (_pollCount >= _maxPollAttempts) {
          _stopPolling();
          emit(PaymentPendingVerification(
            appointmentId: _activeAppointmentId,
            amount: paymentResult.amount,
            pollCount: _pollCount,
          ));
          // Stay in pending — advise user to check later.
          emit(PaymentFailure(
            message: 'Verification is taking longer than expected. '
                'Your payment may still succeed. Check your appointments.',
            appointmentId: _activeAppointmentId,
            amount: paymentResult.amount,
            lastKnownStatus: paymentResult.status,
          ));
        }
    }
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  @override
  Future<void> close() {
    _stopPolling();
    return super.close();
  }
}

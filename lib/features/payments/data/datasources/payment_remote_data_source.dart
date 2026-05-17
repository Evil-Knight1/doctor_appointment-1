import 'package:doctor_appointment/core/errors/exceptions.dart';
import 'package:doctor_appointment/core/services/api_service.dart';
import 'package:doctor_appointment/features/payments/data/models/payment_session_dto.dart';
import 'package:doctor_appointment/features/payments/data/models/payment_status_dto.dart';

/// Contract for the network-level payment operations.
abstract class PaymentRemoteDataSource {
  /// POST /api/Payment/create-session
  Future<PaymentSessionDto> createPaymentSession({
    required int appointmentId,
    required double amount,
    required String currency,
    required int paymentMethodType,
  });

  /// GET /api/Payment/status/{appointmentId}
  Future<PaymentStatusDto> getPaymentStatus({required int appointmentId});

  /// POST /api/Payment/report-completion
  Future<void> reportPaymentCompletion({
    required int appointmentId,
    required bool success,
    String? providerTransactionId,
    String? failureReason,
  });
}

/// Concrete implementation wired to the backend over HTTP via [ApiService].
///
/// All requests carry the JWT auth token automatically (via [AuthTokenInterceptor]).
class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final ApiService _apiService;

  const PaymentRemoteDataSourceImpl(this._apiService);

  // ─── Create Session ────────────────────────────────────────────────────────

  @override
  Future<PaymentSessionDto> createPaymentSession({
    required int appointmentId,
    required double amount,
    required String currency,
    required int paymentMethodType,
  }) async {
    final response = await _apiService.post(
      '/api/Payment/create-session',
      data: {
        'appointmentId': appointmentId,
        'amount': amount,
        'currency': currency,
        'paymentMethodType': paymentMethodType,
      },
    );

    _assertSuccess(response, fallback: 'Failed to create payment session');

    final data = response['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw const ApiException('Invalid response: missing session data');
    }

    return PaymentSessionDto.fromJson(data);
  }

  // ─── Get Status ────────────────────────────────────────────────────────────

  @override
  Future<PaymentStatusDto> getPaymentStatus({
    required int appointmentId,
  }) async {
    final response = await _apiService.get(
      '/api/Payment/status/$appointmentId',
    );

    _assertSuccess(response, fallback: 'Failed to retrieve payment status');

    final data = response['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw const ApiException('Invalid response: missing status data');
    }

    return PaymentStatusDto.fromJson(data);
  }

  // ─── Report Completion (best-effort, not the source of truth) ─────────────

  @override
  Future<void> reportPaymentCompletion({
    required int appointmentId,
    required bool success,
    String? providerTransactionId,
    String? failureReason,
  }) async {
    // Fire-and-forget — swallow errors; the webhook is authoritative.
    try {
      await _apiService.post(
        '/api/Payment/report-completion',
        data: {
          'appointmentId': appointmentId,
          'success': success,
          if (providerTransactionId != null)
            'providerTransactionId': providerTransactionId,
          if (failureReason != null) 'failureReason': failureReason,
        },
      );
    } catch (_) {
      // Intentionally swallowed — webhook is the real confirmation.
    }
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  void _assertSuccess(
    Map<String, dynamic> response, {
    required String fallback,
  }) {
    final success = response['success'] == true;
    if (!success) {
      throw ApiException(_extractMessage(response, fallback: fallback));
    }
  }

  String _extractMessage(
    Map<String, dynamic> json, {
    required String fallback,
  }) {
    final message = json['message'] as String?;
    if (message != null && message.trim().isNotEmpty) return message;
    final errors = json['errors'];
    if (errors is List && errors.isNotEmpty) {
      return errors.map((e) => e.toString()).join(', ');
    }
    return fallback;
  }
}

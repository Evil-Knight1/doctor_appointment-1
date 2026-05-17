import 'package:doctor_appointment/core/errors/exceptions.dart';
import 'package:doctor_appointment/core/errors/failures.dart';
import 'package:doctor_appointment/core/utils/result.dart';
import 'package:doctor_appointment/features/payments/data/datasources/payment_remote_data_source.dart';
import 'package:doctor_appointment/features/payments/domain/entities/payment_result.dart';
import 'package:doctor_appointment/features/payments/domain/entities/payment_session.dart';
import 'package:doctor_appointment/features/payments/domain/repositories/payment_repository.dart';

/// Bridges the domain layer to the remote data source.
///
/// Catches all data-layer exceptions and converts them to typed [Failure]s
/// so cubits never need to handle raw exceptions.
class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDataSource _remoteDataSource;

  const PaymentRepositoryImpl(this._remoteDataSource);

  // ─── Create Session ────────────────────────────────────────────────────────

  @override
  Future<Result<PaymentSession>> createPaymentSession({
    required int appointmentId,
    required double amount,
    required String currency,
    required int paymentMethodType,
  }) async {
    try {
      final dto = await _remoteDataSource.createPaymentSession(
        appointmentId: appointmentId,
        amount: amount,
        currency: currency,
        paymentMethodType: paymentMethodType,
      );
      return Result.success(dto.toDomain());
    } on ApiException catch (e) {
      return Result.failure(ServerFailure(e.message));
    } catch (e) {
      return Result.failure(ServerFailure('Payment session creation failed: $e'));
    }
  }

  // ─── Get Status ────────────────────────────────────────────────────────────

  @override
  Future<Result<PaymentResult>> getPaymentStatus({
    required int appointmentId,
  }) async {
    try {
      final dto = await _remoteDataSource.getPaymentStatus(
        appointmentId: appointmentId,
      );
      return Result.success(dto.toDomain());
    } on ApiException catch (e) {
      return Result.failure(ServerFailure(e.message));
    } catch (e) {
      return Result.failure(ServerFailure('Payment status check failed: $e'));
    }
  }

  // ─── Report Completion ─────────────────────────────────────────────────────

  @override
  Future<Result<void>> reportPaymentCompletion({
    required int appointmentId,
    required bool success,
    String? providerTransactionId,
    String? failureReason,
  }) async {
    try {
      await _remoteDataSource.reportPaymentCompletion(
        appointmentId: appointmentId,
        success: success,
        providerTransactionId: providerTransactionId,
        failureReason: failureReason,
      );
      return Result.success(null);
    } catch (e) {
      // Non-fatal: best-effort report. Webhook is authoritative.
      return Result.success(null);
    }
  }
}

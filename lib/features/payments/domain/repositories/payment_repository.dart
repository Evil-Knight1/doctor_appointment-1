import 'package:doctor_appointment/core/errors/exceptions.dart';
import 'package:doctor_appointment/core/errors/failures.dart';
import 'package:doctor_appointment/core/utils/result.dart';
import 'package:doctor_appointment/features/payments/data/datasources/payment_remote_data_source.dart';

abstract class PaymentRepository {
  Future<Result<String?>> processPayment({
    required int appointmentId,
    required double amount,
    required int paymentMethod,
    String? transactionId,
    String? paymentDetails,
  });
}

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDataSource remoteDataSource;

  PaymentRepositoryImpl(this.remoteDataSource);

  @override
  Future<Result<String?>> processPayment({
    required int appointmentId,
    required double amount,
    required int paymentMethod,
    String? transactionId,
    String? paymentDetails,
  }) async {
    try {
      final url = await remoteDataSource.processPayment(
        appointmentId: appointmentId,
        amount: amount,
        paymentMethod: paymentMethod,
        transactionId: transactionId,
        paymentDetails: paymentDetails,
      );
      return Result.success(url);
    } on ApiException catch (e) {
      return Result.failure(ServerFailure(e.message));
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }
}

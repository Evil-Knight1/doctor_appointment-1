import 'package:doctor_appointment/core/errors/exceptions.dart';
import 'package:doctor_appointment/core/services/api_service.dart';

abstract class PaymentRemoteDataSource {
  Future<void> processPayment({
    required int appointmentId,
    required double amount,
    required int paymentMethod,
    String? transactionId,
    String? paymentDetails,
  });
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final ApiService apiService;

  PaymentRemoteDataSourceImpl(this.apiService);

  @override
  Future<void> processPayment({
    required int appointmentId,
    required double amount,
    required int paymentMethod,
    String? transactionId,
    String? paymentDetails,
  }) async {
    final response = await apiService.post(
      '/api/Payment/process',
      data: {
        'appointmentId': appointmentId,
        'amount': amount,
        'paymentMethod': paymentMethod,
        'transactionId': transactionId,
        'paymentDetails': paymentDetails,
      },
    );

    final success = response['success'] == true;
    if (!success) {
      throw ApiException(_extractMessage(response));
    }
  }

  String _extractMessage(Map<String, dynamic> json) {
    final message = json['message'] as String?;
    if (message != null && message.trim().isNotEmpty) {
      return message;
    }
    final errors = json['errors'];
    if (errors is List && errors.isNotEmpty) {
      return errors.map((e) => e.toString()).join(', ');
    }
    return 'Payment processing failed';
  }
}

import 'package:flutter/services.dart';
import 'package:doctor_appointment/core/logging/log_service.dart';
import 'package:doctor_appointment/core/services/service_locator.dart';

class PaymobSdkService {
  static const MethodChannel _channel = MethodChannel('paymob_sdk_flutter');

  /// Launches the native Paymob SDK.
  /// Returns 'Successfull', 'Rejected', or 'Pending'.
  Future<String> payWithNativeSdk({
    required String publicKey,
    required String clientSecret,
    String? appName,
    int? buttonColor,
  }) async {
    try {
      final String result = await _channel.invokeMethod('payWithNativeSdk', {
        'publicKey': publicKey,
        'clientSecret': clientSecret,
        'appName': appName ?? 'Doctor Appointment',
        'buttonColor': buttonColor ?? 0xFF0D47A1, // default primary color
      });
      return result;
    } on PlatformException catch (e) {
      getIt<LogService>().e('Failed to start Paymob Native SDK: ${e.message}');
      return 'Rejected';
    }
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doctor_appointment/core/utils/result.dart';
import 'package:doctor_appointment/features/appointment/domain/usecases/create_appointment_usecase.dart';
import 'package:doctor_appointment/features/payments/domain/usecases/process_payment_usecase.dart';
import 'package:doctor_appointment/features/payments/logic/payment_state.dart';

class PaymentCubit extends Cubit<PaymentState> {
  final CreateAppointmentUseCase createAppointmentUseCase;
  final ProcessPaymentUseCase processPaymentUseCase;

  PaymentCubit({
    required this.createAppointmentUseCase,
    required this.processPaymentUseCase,
  }) : super(const PaymentInitial());

  Future<void> checkout({
    required int doctorId,
    required int slotId,
    required String reason,
    required int paymentMethod,
    required double amount,
  }) async {
    emit(const PaymentProcessing());

    // 1. Create Appointment
    final appointmentResult = await createAppointmentUseCase(
      CreateAppointmentParams(
        doctorId: doctorId,
        slotId: slotId,
        reason: reason,
        paymentMethod: paymentMethod,
        amount: amount,
      ),
    );

    switch (appointmentResult) {
      case FailureResult():
        emit(PaymentError(appointmentResult.failure.message));
        return;
      case Success():
        final appointment = appointmentResult.data;
        
        // If cash at clinic (3), we don't need to process a gateway payment.
        if (paymentMethod == 3) {
          emit(const PaymentSuccess());
          return;
        }

        // 2. Process Payment for CreditCard (1) or Epay (2)
        final paymentResult = await processPaymentUseCase(
          ProcessPaymentParams(
            appointmentId: appointment.id,
            amount: amount,
            paymentMethod: paymentMethod,
            // Mock transaction ID for simulation
            transactionId: 'TXN-${DateTime.now().millisecondsSinceEpoch}',
            paymentDetails: 'Simulated payment',
          ),
        );

        switch (paymentResult) {
          case FailureResult():
            emit(PaymentError(paymentResult.failure.message));
          case Success():
            final paymentUrl = paymentResult.data;
            if (paymentUrl != null && paymentUrl.isNotEmpty) {
              emit(PaymentRequiresAction(paymentUrl));
            } else {
              emit(const PaymentSuccess());
            }
        }
    }
  }
}

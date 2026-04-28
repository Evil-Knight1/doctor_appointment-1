import 'package:equatable/equatable.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object> get props => [];
}

class PaymentInitial extends PaymentState {
  const PaymentInitial();
}

class PaymentProcessing extends PaymentState {
  const PaymentProcessing();
}

class PaymentSuccess extends PaymentState {
  const PaymentSuccess();
}

class PaymentRequiresAction extends PaymentState {
  final String paymentUrl;

  const PaymentRequiresAction(this.paymentUrl);

  @override
  List<Object> get props => [paymentUrl];
}

class PaymentError extends PaymentState {
  final String message;

  const PaymentError(this.message);

  @override
  List<Object> get props => [message];
}

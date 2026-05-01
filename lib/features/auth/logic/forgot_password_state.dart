
sealed class ForgotPasswordState {
  const ForgotPasswordState();
}

class ForgotPasswordInitial extends ForgotPasswordState {
  const ForgotPasswordInitial();
}

class ForgotPasswordLoading extends ForgotPasswordState {
  const ForgotPasswordLoading();
}

class ForgotPasswordSuccess extends ForgotPasswordState {
  final String message;
  const ForgotPasswordSuccess(this.message);
}

class OtpVerifiedSuccess extends ForgotPasswordState {
  final String token;
  const OtpVerifiedSuccess(this.token);
}

class PasswordResetSuccess extends ForgotPasswordState {
  const PasswordResetSuccess();
}

class ForgotPasswordFailure extends ForgotPasswordState {
  final String message;
  final Map<String, String> fieldErrors;

  const ForgotPasswordFailure(this.message, {this.fieldErrors = const {}});
}

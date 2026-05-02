abstract class Failure {
  final String message;

  const Failure(this.message);

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  final int? statusCode;
  /// Per-field validation errors returned by the server.
  /// Keys are field names (e.g. 'password', 'phone'), values are the error messages.
  final Map<String, String> fieldErrors;

  const ServerFailure(
    super.message, {
    this.statusCode,
    this.fieldErrors = const {},
  });
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}

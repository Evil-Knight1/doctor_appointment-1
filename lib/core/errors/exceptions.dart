class ApiException implements Exception {
  final String message;
  final int? statusCode;
  /// Per-field validation errors (e.g. from ASP.NET model state).
  final Map<String, String> fieldErrors;

  const ApiException(
    this.message, {
    this.statusCode,
    this.fieldErrors = const {},
  });

  @override
  String toString() => message;
}

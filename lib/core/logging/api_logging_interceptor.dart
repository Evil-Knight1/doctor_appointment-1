import 'package:dio/dio.dart';
import 'package:doctor_appointment/core/logging/log_service.dart';

/// Dio interceptor that logs every request, response, and error in a
/// structured, human-readable format including method, endpoint, status
/// code, elapsed time, request inputs, and response body.
class ApiLoggingInterceptor extends Interceptor {
  final LogService _logService;

  ApiLoggingInterceptor(this._logService);

  // ── Request ────────────────────────────────────────────────────────────────

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Store the start timestamp so we can compute elapsed time later.
    options.extra['_startTime'] = DateTime.now().millisecondsSinceEpoch;

    final buffer = StringBuffer()
      ..writeln('┌─── API REQUEST ─────────────────────────────────────────')
      ..writeln('│ ${options.method.padRight(6)} ${options.baseUrl}${options.path}')
      ..writeln('├─────────────────────────────────────────────────────────');

    // Headers (skip internal / sensitive keys)
    final filteredHeaders = Map<String, dynamic>.from(options.headers)
      ..remove('Authorization'); // never log tokens
    if (filteredHeaders.isNotEmpty) {
      buffer.writeln('│ Headers : ${_compact(filteredHeaders)}');
    }

    // Query params
    if (options.queryParameters.isNotEmpty) {
      buffer.writeln('│ Query   : ${_compact(options.queryParameters)}');
    }

    // Request body / data
    if (options.data != null) {
      buffer.writeln('│ Body    : ${_truncate(options.data.toString())}');
    }

    buffer.write('└─────────────────────────────────────────────────────────');

    _logService.i(buffer.toString());
    super.onRequest(options, handler);
  }

  // ── Response ───────────────────────────────────────────────────────────────

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final elapsed = _elapsed(response.requestOptions);
    final status = response.statusCode ?? 0;
    final emoji = status < 400 ? '✅' : '⚠️';

    final buffer = StringBuffer()
      ..writeln('┌─── API RESPONSE $emoji ──────────────────────────────────────')
      ..writeln('│ ${response.requestOptions.method.padRight(6)} ${response.requestOptions.path}')
      ..writeln('│ Status  : $status  |  Time: ${elapsed}ms')
      ..writeln('├─────────────────────────────────────────────────────────')
      ..writeln('│ Body    : ${_truncate(response.data?.toString() ?? 'null')}')
      ..write('└─────────────────────────────────────────────────────────');

    _logService.i(buffer.toString());
    super.onResponse(response, handler);
  }

  // ── Error ──────────────────────────────────────────────────────────────────

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final elapsed = _elapsed(err.requestOptions);
    final status = err.response?.statusCode ?? 0;

    final buffer = StringBuffer()
      ..writeln('┌─── API ERROR ❌ ─────────────────────────────────────────')
      ..writeln('│ ${err.requestOptions.method.padRight(6)} ${err.requestOptions.path}')
      ..writeln('│ Status  : $status  |  Time: ${elapsed}ms')
      ..writeln('│ Type    : ${err.type.name}')
      ..writeln('├─────────────────────────────────────────────────────────');

    if (err.message != null) {
      buffer.writeln('│ Message : ${err.message}');
    }
    if (err.response?.data != null) {
      buffer.writeln('│ Response: ${_truncate(err.response!.data.toString())}');
    }
    buffer.write('└─────────────────────────────────────────────────────────');

    _logService.e(buffer.toString(), err, err.stackTrace);
    super.onError(err, handler);
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Returns elapsed milliseconds since the request was sent, or -1 if unknown.
  int _elapsed(RequestOptions options) {
    final start = options.extra['_startTime'];
    if (start is int) {
      return DateTime.now().millisecondsSinceEpoch - start;
    }
    return -1;
  }

  /// Truncates a string to [maxLen] characters so logs stay readable.
  String _truncate(String value, {int maxLen = 500}) {
    if (value.length <= maxLen) return value;
    return '${value.substring(0, maxLen)}… [+${value.length - maxLen} chars]';
  }

  /// Converts a map to a compact, single-line string.
  String _compact(Map<dynamic, dynamic> map) {
    return map.entries.map((e) => '${e.key}: ${e.value}').join(', ');
  }
}

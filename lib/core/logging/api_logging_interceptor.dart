import 'package:dio/dio.dart';
import 'package:doctor_appointment/core/logging/log_service.dart';

class ApiLoggingInterceptor extends Interceptor {
  final LogService _logService;

  ApiLoggingInterceptor(this._logService);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logService.i(
      'NETWORK REQUEST [${options.method}] => PATH: ${options.path}\n'
      'HEADERS: ${options.headers}\n'
      'DATA: ${options.data}\n'
      'QUERY PARAMS: ${options.queryParameters}',
    );
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logService.i(
      'NETWORK RESPONSE [${response.statusCode}] => PATH: ${response.requestOptions.path}\n'
      'DATA: ${response.data}',
    );
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logService.e(
      'NETWORK ERROR [${err.response?.statusCode}] => PATH: ${err.requestOptions.path}\n'
      'MESSAGE: ${err.message}\n'
      'RESPONSE DATA: ${err.response?.data}',
      err,
      err.stackTrace,
    );
    super.onError(err, handler);
  }
}

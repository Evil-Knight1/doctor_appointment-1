import 'dart:async';

import 'package:dio/dio.dart';
import 'package:doctor_appointment/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:doctor_appointment/features/auth/data/datasources/auth_remote_data_source.dart';

class AuthTokenInterceptor extends Interceptor {
  final AuthLocalDataSource localDataSource;
  final AuthRemoteDataSource remoteDataSource;
  final Dio dio;

  bool _isRefreshing = false;
  Completer<void>? _refreshCompleter;

  AuthTokenInterceptor({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.dio,
  });

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final session = await localDataSource.getCachedSession();
    final token = session?.token ?? '';
    if (token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = err.response?.statusCode;
    final requestOptions = err.requestOptions;

    if (statusCode != 401 || _shouldSkipRefresh(requestOptions)) {
      return handler.next(err);
    }

    if (_isRefreshing) {
      await _refreshCompleter?.future;
      final retryResponse = await _retryWithUpdatedToken(requestOptions);
      if (retryResponse != null) {
        return handler.resolve(retryResponse);
      }
      return handler.next(err);
    }

    _isRefreshing = true;
    _refreshCompleter = Completer<void>();

    try {
      final session = await localDataSource.getCachedSession();
      if (session == null) {
        _refreshCompleter?.complete();
        _isRefreshing = false;
        return handler.next(err);
      }

      final refreshed = await remoteDataSource.refreshToken(
        token: session.token,
        refreshToken: session.refreshToken,
      );
      await localDataSource.cacheAuthSession(refreshed);

      _refreshCompleter?.complete();
      _isRefreshing = false;

      final retryResponse = await _retryWithUpdatedToken(requestOptions);
      if (retryResponse != null) {
        return handler.resolve(retryResponse);
      }
      return handler.next(err);
    } catch (_) {
      _refreshCompleter?.complete();
      _isRefreshing = false;
      return handler.next(err);
    }
  }

  bool _shouldSkipRefresh(RequestOptions options) {
    final isRetry = options.extra['retry'] == true;
    final path = options.path;
    return isRetry || path.contains('/api/Auth/refresh');
  }

  Future<Response<dynamic>?> _retryWithUpdatedToken(
    RequestOptions requestOptions,
  ) async {
    final session = await localDataSource.getCachedSession();
    final token = session?.token ?? '';
    if (token.isEmpty) {
      return null;
    }

    requestOptions.headers['Authorization'] = 'Bearer $token';
    requestOptions.extra['retry'] = true;
    return dio.fetch(requestOptions);
  }
}

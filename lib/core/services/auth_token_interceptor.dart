import 'dart:async';

import 'package:dio/dio.dart';
import 'package:doctor_appointment/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:doctor_appointment/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:doctor_appointment/core/services/shared_preferences_helper.dart';
import 'package:doctor_appointment/core/utils/go_router.dart';

class AuthTokenInterceptor extends Interceptor {
  final AuthLocalDataSource localDataSource;
  final AuthRemoteDataSource remoteDataSource;
  final Dio dio;

  bool _isRefreshing = false;

  /// All concurrent 401 requests wait on this single future.
  /// Using a Completer that is only completed once via [_safeComplete].
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
    // Prefer SharedPrefs token (always up-to-date after a refresh) over
    // the cached session, which may lag behind.
    final token =
        SharedPreferencesHelper.getToken() ??
        (await localDataSource.getCachedSession())?.token ??
        '';

    if (!_shouldSkipRefresh(options) && token.isNotEmpty) {
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

    // Only handle 401s that are not auth endpoints / retries.
    if (statusCode != 401 || _shouldSkipRefresh(requestOptions)) {
      return handler.next(err);
    }

    // -------------------------------------------------------------------
    // If a refresh is already in-flight, wait for it then retry once.
    // -------------------------------------------------------------------
    if (_isRefreshing) {
      try {
        await _refreshCompleter?.future;
        final retryResponse = await _retryWithUpdatedToken(requestOptions);
        if (retryResponse != null) return handler.resolve(retryResponse);
      } catch (_) {
        // Refresh failed — fall through to login redirect.
      }
      _navigateToLogin();
      return handler.next(err);
    }

    // -------------------------------------------------------------------
    // This is the first 401 — start a single refresh cycle.
    // -------------------------------------------------------------------
    _isRefreshing = true;
    _refreshCompleter = Completer<void>();

    try {
      final session = await localDataSource.getCachedSession();
      if (session == null) {
        _safeComplete();
        _navigateToLogin();
        return handler.next(err);
      }

      final refreshed = await remoteDataSource.refreshToken(
        token: session.token,
        refreshToken: session.refreshToken,
      );

      // Persist the new tokens in BOTH storage layers so onRequest always
      // picks up the freshest token.
      await localDataSource.cacheAuthSession(refreshed);
      await SharedPreferencesHelper.saveToken(refreshed.token);

      _safeComplete();

      final retryResponse = await _retryWithUpdatedToken(requestOptions);
      if (retryResponse != null) return handler.resolve(retryResponse);

      _navigateToLogin();
      return handler.next(err);
    } catch (e) {
      _safeCompleteError(e);
      _navigateToLogin();
      return handler.next(err);
    } finally {
      _isRefreshing = false;
    }
  }

  // ── helpers ─────────────────────────────────────────────────────────────

  /// Complete the shared completer exactly once (guards double-complete).
  void _safeComplete() {
    if (_refreshCompleter != null && !_refreshCompleter!.isCompleted) {
      _refreshCompleter!.complete();
    }
  }

  void _safeCompleteError(Object error) {
    if (_refreshCompleter != null && !_refreshCompleter!.isCompleted) {
      _refreshCompleter!.completeError(error);
    }
  }

  bool _shouldSkipRefresh(RequestOptions options) {
    final isRetry = options.extra['retry'] == true;
    final path = options.path;
    return isRetry ||
        path.contains('/api/Auth/refresh') ||
        path.contains('/api/Auth/login') ||
        path.contains('/api/Auth/register');
  }

  Future<Response<dynamic>?> _retryWithUpdatedToken(
    RequestOptions requestOptions,
  ) async {
    final token =
        SharedPreferencesHelper.getToken() ??
        (await localDataSource.getCachedSession())?.token ??
        '';
    if (token.isEmpty) return null;

    requestOptions.headers['Authorization'] = 'Bearer $token';
    requestOptions.extra['retry'] = true;
    return dio.fetch(requestOptions);
  }

  void _navigateToLogin() {
    SharedPreferencesHelper.removeToken();
    SharedPreferencesHelper.removeUserData();
    localDataSource.clearSession();
    AppRouter.router.go(AppRouter.kLoginView);
  }
}

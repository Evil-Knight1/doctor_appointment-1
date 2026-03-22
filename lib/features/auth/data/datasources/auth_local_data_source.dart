import 'package:doctor_appointment/core/services/secure_storage_service.dart';
import 'package:doctor_appointment/features/auth/domain/entities/auth_response.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheAuthSession(AuthResponse response);
  Future<AuthResponse?> getCachedSession();
  Future<void> clearSession();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const _tokenKey = 'auth_token';
  static const _refreshTokenKey = 'auth_refresh_token';
  static const _emailKey = 'auth_email';
  static const _roleKey = 'auth_role';
  static const _userIdKey = 'auth_user_id';
  static const _expiresAtKey = 'auth_expires_at';

  final SecureStorageService storage;

  AuthLocalDataSourceImpl(this.storage);

  @override
  Future<void> cacheAuthSession(AuthResponse response) async {
    await storage.write(key: _tokenKey, value: response.token);
    await storage.write(key: _refreshTokenKey, value: response.refreshToken);
    await storage.write(key: _emailKey, value: response.email);
    await storage.write(key: _roleKey, value: response.role);
    await storage.write(key: _userIdKey, value: response.userId.toString());
    await storage.write(
      key: _expiresAtKey,
      value: response.expiresAt.toIso8601String(),
    );
  }

  @override
  Future<AuthResponse?> getCachedSession() async {
    final token = await storage.read(key: _tokenKey);
    final refreshToken = await storage.read(key: _refreshTokenKey);
    if (token == null || refreshToken == null) {
      return null;
    }

    final email = await storage.read(key: _emailKey) ?? '';
    final role = await storage.read(key: _roleKey) ?? '';
    final userIdRaw = await storage.read(key: _userIdKey);
    final expiresAtRaw = await storage.read(key: _expiresAtKey);

    final userId = int.tryParse(userIdRaw ?? '') ?? 0;
    final expiresAt = DateTime.tryParse(expiresAtRaw ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0);

    return AuthResponse(
      token: token,
      refreshToken: refreshToken,
      email: email,
      role: role,
      userId: userId,
      expiresAt: expiresAt,
    );
  }

  @override
  Future<void> clearSession() async {
    await storage.delete(key: _tokenKey);
    await storage.delete(key: _refreshTokenKey);
    await storage.delete(key: _emailKey);
    await storage.delete(key: _roleKey);
    await storage.delete(key: _userIdKey);
    await storage.delete(key: _expiresAtKey);
  }
}

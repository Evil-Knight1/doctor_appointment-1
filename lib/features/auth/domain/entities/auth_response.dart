class AuthResponse {
  final String token;
  final String refreshToken;
  final String email;
  final String role;
  final int userId;
  final DateTime expiresAt;

  const AuthResponse({
    required this.token,
    required this.refreshToken,
    required this.email,
    required this.role,
    required this.userId,
    required this.expiresAt,
  });
}

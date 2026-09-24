class AuthException implements Exception {
  const AuthException(this.code, this.message);

  final String code;
  final String message;

  bool get requiresSignIn => const {
    'invalid_grant',
    'invalid_refresh_token',
    'refresh_token_expired',
  }.contains(code.toLowerCase());

  @override
  String toString() => message;
}

class AuthException implements Exception {
  const AuthException(this.code, this.message);

  final String code;
  final String message;

  bool get requiresSignIn => const {
    'invalid_grant',
    'invalid_refresh_token',
    'refresh_token_expired',
    'refresh_token_not_found',
    'refresh_token_already_used',
    'session_not_found',
  }.contains(code.toLowerCase());

  @override
  String toString() => message;
}

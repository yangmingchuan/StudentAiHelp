class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.subject,
    required this.username,
    required this.expiresAt,
  });

  factory AuthSession.fromTokenResponse(
    Map<String, dynamic> json, {
    String? fallbackRefreshToken,
    required String username,
  }) {
    final expiresIn = switch (json['expires_in']) {
      final int value => value,
      final num value => value.toInt(),
      final String value => int.tryParse(value) ?? 7200,
      _ => 7200,
    };

    return AuthSession(
      accessToken: json['access_token'] as String? ?? '',
      refreshToken:
          json['refresh_token'] as String? ?? fallbackRefreshToken ?? '',
      subject: json['sub']?.toString() ?? '',
      username: username,
      expiresAt: DateTime.now().toUtc().add(Duration(seconds: expiresIn)),
    );
  }

  final String accessToken;
  final String refreshToken;
  final String subject;
  final String username;
  final DateTime expiresAt;

  bool get shouldRefresh =>
      DateTime.now().toUtc().add(const Duration(minutes: 1)).isAfter(expiresAt);
}

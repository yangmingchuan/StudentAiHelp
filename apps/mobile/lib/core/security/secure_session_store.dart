import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:little_hero/core/config/app_environment.dart';
import 'package:little_hero/core/network/api_client.dart';
import 'package:little_hero/features/auth/domain/auth_session.dart';
import 'package:uuid/uuid.dart';

final secureSessionStoreProvider = Provider<SecureSessionStore>((ref) {
  final environment = ref.watch(appEnvironmentProvider);
  return SecureSessionStore(
    const FlutterSecureStorage(),
    namespace: environment.sessionNamespace,
    migrateLegacy:
        environment.sessionNamespace ==
        AppEnvironment.legacyDevelopment.sessionNamespace,
  );
});

class SecureSessionStore {
  const SecureSessionStore(
    this._storage, {
    this.namespace = 'default',
    this.migrateLegacy = true,
  });
  final String namespace;
  final bool migrateLegacy;
  String get _sessionKey =>
      'auth_session_v2_${base64Url.encode(utf8.encode(namespace))}';

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _subjectKey = 'auth_subject';
  static const _usernameKey = 'auth_username';
  static const _expiresAtKey = 'access_token_expires_at';
  static const _deviceIdKey = 'device_id';

  final FlutterSecureStorage _storage;

  Future<AuthSession?> readSession() async {
    final encoded = await _storage.read(key: _sessionKey);
    if (encoded != null) {
      // A signed-out tombstone also prevents re-importing obsolete legacy tokens.
      try {
        final decoded = jsonDecode(encoded);
        if (decoded == null) return null;
        final data = decoded as Map<String, dynamic>;
        return AuthSession(
          accessToken: data['accessToken'] as String,
          refreshToken: data['refreshToken'] as String,
          subject: data['subject'] as String,
          username: data['username'] as String,
          expiresAt: DateTime.parse(data['expiresAt'] as String),
        );
      } on FormatException {
        return null;
      } on TypeError {
        return null;
      }
    }
    if (!migrateLegacy) return null;
    final values = await Future.wait([
      _storage.read(key: _accessTokenKey),
      _storage.read(key: _refreshTokenKey),
      _storage.read(key: _subjectKey),
      _storage.read(key: _usernameKey),
      _storage.read(key: _expiresAtKey),
    ]);
    final accessToken = values[0];
    final refreshToken = values[1];
    final subject = values[2];
    final username = values[3];
    final expiresAt = DateTime.tryParse(values[4] ?? '');

    if (accessToken == null ||
        refreshToken == null ||
        subject == null ||
        username == null ||
        expiresAt == null) {
      return null;
    }

    final session = AuthSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
      subject: subject,
      username: username,
      expiresAt: expiresAt,
    );
    await saveSession(session);
    return session;
  }

  Future<void> saveSession(AuthSession session) async {
    // Store the rotating token pair together, never as five independent writes.
    await _storage.write(
      key: _sessionKey,
      value: jsonEncode({
        'accessToken': session.accessToken,
        'refreshToken': session.refreshToken,
        'subject': session.subject,
        'username': session.username,
        'expiresAt': session.expiresAt.toUtc().toIso8601String(),
      }),
    );
  }

  Future<String> readOrCreateDeviceId() async {
    final existing = await _storage.read(key: _deviceIdKey);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }

    final deviceId = const Uuid().v4();
    await _storage.write(key: _deviceIdKey, value: deviceId);
    return deviceId;
  }

  Future<void> clearSession() async {
    await _storage.write(key: _sessionKey, value: 'null');
    if (!migrateLegacy) return;
    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
      _storage.delete(key: _subjectKey),
      _storage.delete(key: _usernameKey),
      _storage.delete(key: _expiresAtKey),
    ]);
  }

  Future<void> clear() => clearSession();
}

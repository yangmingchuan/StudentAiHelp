import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:little_hero/features/auth/domain/auth_session.dart';
import 'package:uuid/uuid.dart';

final secureSessionStoreProvider = Provider<SecureSessionStore>((ref) {
  return const SecureSessionStore(FlutterSecureStorage());
});

class SecureSessionStore {
  const SecureSessionStore(this._storage);

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _subjectKey = 'auth_subject';
  static const _usernameKey = 'auth_username';
  static const _expiresAtKey = 'access_token_expires_at';
  static const _deviceIdKey = 'device_id';

  final FlutterSecureStorage _storage;

  Future<AuthSession?> readSession() async {
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

    return AuthSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
      subject: subject,
      username: username,
      expiresAt: expiresAt,
    );
  }

  Future<void> saveSession(AuthSession session) async {
    await Future.wait([
      _storage.write(key: _accessTokenKey, value: session.accessToken),
      _storage.write(key: _refreshTokenKey, value: session.refreshToken),
      _storage.write(key: _subjectKey, value: session.subject),
      _storage.write(key: _usernameKey, value: session.username),
      _storage.write(
        key: _expiresAtKey,
        value: session.expiresAt.toUtc().toIso8601String(),
      ),
    ]);
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
    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
      _storage.delete(key: _subjectKey),
      _storage.delete(key: _usernameKey),
      _storage.delete(key: _expiresAtKey),
    ]);
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<void> clear() => clearSession();
}

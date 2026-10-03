import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:little_hero/core/network/api_client.dart';
import 'package:little_hero/features/auth/application/auth_controller.dart';

final parentPinStoreProvider = Provider<ParentPinStore>((ref) {
  final owner = ref.watch(
    authControllerProvider.select((value) => value.asData?.value?.subject),
  );
  if (owner == null) throw StateError('请先登录');
  final namespace = ref.watch(appEnvironmentProvider).sessionNamespace;
  return ParentPinStore(
    const FlutterSecureStorage(),
    scope: '$namespace:$owner',
  );
});

class ParentPinException implements Exception {
  const ParentPinException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Device-local, account-scoped parental gate. No PIN or recovery secret is
/// written to SQLite, synced, logged, or kept in plaintext.
class ParentPinStore {
  ParentPinStore(
    this.storage, {
    required String scope,
    DateTime Function()? now,
  }) : key = 'parent_pin_v1_${base64Url.encode(utf8.encode(scope))}',
       _now = now ?? DateTime.now;

  final FlutterSecureStorage storage;
  final String key;
  final DateTime Function() _now;
  final _algorithm = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: 100000,
    bits: 256,
  );

  Future<Map<String, dynamic>?> _read() async {
    final raw = await storage.read(key: key);
    if (raw == null) return null;
    try {
      final value = jsonDecode(raw) as Map<String, dynamic>;
      if (value['version'] != 1 ||
          base64Decode(value['salt'] as String).length != 16 ||
          base64Decode(value['hash'] as String).length != 32) {
        throw const FormatException();
      }
      return value;
    } catch (_) {
      throw const ParentPinException('家长密码记录无法读取，请通过“忘记密码”重新设置。');
    }
  }

  Future<bool> isConfigured() async => await _read() != null;

  Future<List<int>> _hash(String pin, List<int> salt) async =>
      (await _algorithm.deriveKey(
        secretKey: SecretKey(utf8.encode(pin)),
        nonce: salt,
      )).extractBytes();

  Future<void> setPin(String pin, {bool replace = false}) async {
    if (!RegExp(r'^[0-9]{4}$').hasMatch(pin)) {
      throw const ParentPinException('请输入 4 位数字密码。');
    }
    // Only the authenticated reset/change flow may replace an existing PIN.
    if (!replace && await isConfigured()) {
      throw const ParentPinException('已设置家长密码，请先解锁。');
    }
    final random = Random.secure();
    final salt = List<int>.generate(16, (_) => random.nextInt(256));
    await storage.write(
      key: key,
      value: jsonEncode({
        'version': 1,
        'salt': base64Encode(salt),
        'hash': base64Encode(await _hash(pin, salt)),
        'failures': 0,
        'lockedUntil': 0,
      }),
    );
  }

  Future<void> verify(String pin) async {
    final value = await _read();
    if (value == null) throw const ParentPinException('请先设置家长密码。');
    final until = value['lockedUntil'] as int? ?? 0;
    final remaining = until - _now().millisecondsSinceEpoch;
    if (remaining > 0) {
      throw ParentPinException('尝试次数较多，请 ${(remaining / 1000).ceil()} 秒后再试。');
    }
    if (!RegExp(r'^[0-9]{4}$').hasMatch(pin)) {
      throw const ParentPinException('请输入 4 位数字密码。');
    }
    final actual = await _hash(pin, base64Decode(value['salt'] as String));
    final expected = base64Decode(value['hash'] as String);
    var difference = 0;
    for (var i = 0; i < expected.length; i++) {
      difference |= actual[i] ^ expected[i];
    }
    if (difference != 0) {
      final failures = (value['failures'] as int? ?? 0) + 1;
      value['failures'] = failures >= 5 ? 0 : failures;
      value['lockedUntil'] = failures >= 5
          ? _now().add(const Duration(seconds: 60)).millisecondsSinceEpoch
          : 0;
      await storage.write(key: key, value: jsonEncode(value));
      throw ParentPinException(
        failures >= 5 ? '连续输错 5 次，请 60 秒后再试，或验证账号密码重设。' : '家长密码不正确，请重试。',
      );
    }
    value['failures'] = 0;
    value['lockedUntil'] = 0;
    await storage.write(key: key, value: jsonEncode(value));
  }
}

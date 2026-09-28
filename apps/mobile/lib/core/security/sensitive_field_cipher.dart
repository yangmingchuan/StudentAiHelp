import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final sensitiveFieldCipherProvider = Provider<SensitiveFieldCipher>((ref) {
  return SensitiveFieldCipher(const FlutterSecureStorage());
});

/// Field-level protection for health text stored in the local SQLite database.
///
/// The 256-bit key stays in the OS secure-storage service. Values written by
/// earlier builds remain readable and are rewritten encrypted on the next load.
class SensitiveFieldCipher {
  SensitiveFieldCipher(this._storage);

  static const _keyName = 'little_hero_health_field_key_v1';
  static const _prefix = 'lhc1.';
  static final _algorithm = AesGcm.with256bits();

  final FlutterSecureStorage _storage;
  Future<SecretKey>? _key;

  bool isProtected(String value) => value.startsWith(_prefix);

  Future<String> encrypt(String value) async {
    if (value.isEmpty || isProtected(value)) return value;
    final secretBox = await _algorithm.encrypt(
      utf8.encode(value),
      secretKey: await _readOrCreateKey(),
    );
    return _prefix +
        [
          base64Url.encode(secretBox.nonce),
          base64Url.encode(secretBox.cipherText),
          base64Url.encode(secretBox.mac.bytes),
        ].join('.');
  }

  Future<String> decrypt(String value) async {
    try {
      return await decryptStrict(value);
    } catch (_) {
      return '';
    }
  }

  /// Sync must stop on an unreadable key, rather than replacing cloud text with ''.
  Future<String> decryptStrict(String value) async {
    if (value.isEmpty || !isProtected(value)) return value;
    final parts = value.substring(_prefix.length).split('.');
    if (parts.length != 3) throw const FormatException('健康数据无法解密');
    final secretBox = SecretBox(
      base64Url.decode(parts[1]),
      nonce: base64Url.decode(parts[0]),
      mac: Mac(base64Url.decode(parts[2])),
    );
    final clearText = await _algorithm.decrypt(
      secretBox,
      secretKey: await _readOrCreateKey(),
    );
    return utf8.decode(clearText);
  }

  Future<SecretKey> _readOrCreateKey() {
    return _key ??= _loadKey();
  }

  Future<SecretKey> _loadKey() async {
    final stored = await _storage.read(key: _keyName);
    if (stored != null) {
      try {
        return SecretKey(base64Url.decode(stored));
      } on FormatException {
        // Replace a malformed legacy key with a new device-bound key.
      }
    }
    final key = await _algorithm.newSecretKey();
    final bytes = await key.extractBytes();
    await _storage.write(key: _keyName, value: base64Url.encode(bytes));
    return SecretKey(Uint8List.fromList(bytes));
  }
}

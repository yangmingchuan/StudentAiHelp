import 'dart:math';

/// Safe in JSON/JavaScript while avoiding device-local autoincrement collisions.
abstract final class SyncId {
  static final _random = Random.secure();
  static int next() =>
      (1 << 40) +
      _random.nextInt(1 << 25) * (1 << 26) +
      _random.nextInt(1 << 26);
}

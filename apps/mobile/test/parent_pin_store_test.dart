import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:little_hero/features/parent_access/data/parent_pin_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const storage = FlutterSecureStorage();
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test(
    'PIN is hashed, survives reopening, and is isolated per account',
    () async {
      final store = ParentPinStore(storage, scope: 'dev:alice');
      expect(await store.isConfigured(), isFalse);
      await store.setPin('0123');
      final raw = await storage.read(key: store.key);
      expect(raw, isNot(contains('0123')));
      expect(
        await ParentPinStore(storage, scope: 'dev:alice').isConfigured(),
        isTrue,
      );
      await ParentPinStore(storage, scope: 'dev:alice').verify('0123');
      expect(
        await ParentPinStore(storage, scope: 'dev:bob').isConfigured(),
        isFalse,
      );
      expect(
        await ParentPinStore(storage, scope: 'prod:alice').isConfigured(),
        isFalse,
      );
      await expectLater(
        store.setPin('9876'),
        throwsA(isA<ParentPinException>()),
      );
      await expectLater(
        store.verify('1234'),
        throwsA(isA<ParentPinException>()),
      );
    },
  );

  test(
    'five failures persist a cooldown; reopening cannot bypass it',
    () async {
      var now = DateTime(2026, 9, 29, 12);
      ParentPinStore open() =>
          ParentPinStore(storage, scope: 'alice', now: () => now);
      await open().setPin('0123');
      for (var i = 0; i < 5; i++) {
        await expectLater(
          open().verify('9999'),
          throwsA(isA<ParentPinException>()),
        );
      }
      await expectLater(
        open().verify('0123'),
        throwsA(isA<ParentPinException>()),
      );
      now = now.add(const Duration(seconds: 61));
      await open().verify('0123');
    },
  );

  test(
    'replacement invalidates old PIN and malformed storage fails closed',
    () async {
      final store = ParentPinStore(storage, scope: 'alice');
      await expectLater(store.setPin('12'), throwsA(isA<ParentPinException>()));
      await expectLater(
        store.setPin('abcd'),
        throwsA(isA<ParentPinException>()),
      );
      await store.setPin('0123');
      await store.setPin('9876', replace: true);
      await expectLater(
        store.verify('0123'),
        throwsA(isA<ParentPinException>()),
      );
      await store.verify('9876');
      await storage.write(key: store.key, value: 'broken');
      await expectLater(
        store.isConfigured(),
        throwsA(isA<ParentPinException>()),
      );
      await store.setPin('5678', replace: true);
      await store.verify('5678');
    },
  );
}

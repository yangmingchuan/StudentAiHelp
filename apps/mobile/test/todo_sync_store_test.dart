import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:little_hero/core/database/local_database.dart';
import 'package:little_hero/core/security/sensitive_field_cipher.dart';
import 'package:little_hero/core/sync/todo_sync_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test(
    'offline writes reach a second database and health text uses its own key',
    () async {
      final first = LocalDatabase.forTesting(
        NativeDatabase.memory(),
        syncEnabled: true,
      );
      final second = LocalDatabase.forTesting(
        NativeDatabase.memory(),
        syncEnabled: true,
      );
      addTearDown(first.close);
      addTearDown(second.close);
      final source = TodoSyncStore(
        first,
        SensitiveFieldCipher(const FlutterSecureStorage()),
      );
      final target = TodoSyncStore(
        second,
        SensitiveFieldCipher(const FlutterSecureStorage()),
      );
      await first.customStatement(
        "INSERT INTO local_children(id,nickname) VALUES(1,'孩子')",
      );
      await first.customStatement(
        "INSERT INTO local_medication_members(id,name,allergy_note) VALUES(100,'成员',?)",
        [await source.cipher.encrypt('青霉素')],
      );
      final changes = await source.pending();
      expect(changes.length, 2);
      expect((changes.last['payload'] as Map)['allergy_note'], '青霉素');
      for (var i = 0; i < changes.length; i++) {
        final row = changes[i];
        await target.apply({
          'accepted': [],
          'conflicts': [],
          'rows': [
            {
              'entity': row['entity'],
              'key': row['key'],
              'payload': row['payload'],
              'revision': i + 1,
              'deleted': false,
            },
          ],
          'cursor': i + 1,
        });
      }
      final fetched = await second
          .customSelect(
            'SELECT allergy_note FROM local_medication_members WHERE id=100',
          )
          .getSingle();
      final protected = fetched.read<String>('allergy_note');
      expect(protected, startsWith('lhc1.'));
      expect(await target.cipher.decrypt(protected), '青霉素');
      expect(
        (await second
                .customSelect('SELECT nickname FROM local_children WHERE id=1')
                .getSingle())
            .read<String>('nickname'),
        '孩子',
      );
      expect(await target.pending(), isEmpty);
    },
  );

  test(
    'conflicting same-record edits preserve local change until resolved',
    () async {
      final db = LocalDatabase.forTesting(
        NativeDatabase.memory(),
        syncEnabled: true,
      );
      addTearDown(db.close);
      final store = TodoSyncStore(
        db,
        SensitiveFieldCipher(const FlutterSecureStorage()),
      );
      await db.customStatement(
        "INSERT INTO local_children(id,nickname) VALUES(1,'旧名')",
      );
      final initial = (await store.pending()).single;
      await store.apply({
        'accepted': [
          {
            'entity': 'children',
            'key': initial['key'],
            'operation_id': initial['operation_id'],
            'revision': 1,
          },
        ],
        'conflicts': [],
        'rows': [],
        'cursor': 1,
      });
      await db.customStatement(
        "UPDATE local_children SET nickname='本机' WHERE id=1",
      );
      final pending = (await store.pending()).single;
      await store.apply({
        'accepted': [],
        'conflicts': [
          {
            'entity': 'children',
            'key': pending['key'],
            'operation_id': pending['operation_id'],
            'remote': {
              'revision': 2,
              'deleted': false,
              'payload': {'id': 1, 'nickname': '另一台设备'},
            },
          },
        ],
        'rows': [],
        'cursor': 2,
      });
      expect(await store.conflictCount(), 1);
      expect(await store.pending(), isEmpty);
      expect(
        (await db
                .customSelect('SELECT nickname FROM local_children')
                .getSingle())
            .read<String>('nickname'),
        '本机',
      );
      await store.resolveConflicts(keepLocal: false);
      expect(
        (await db
                .customSelect('SELECT nickname FROM local_children')
                .getSingle())
            .read<String>('nickname'),
        '另一台设备',
      );
      expect(await store.conflictCount(), 0);
    },
  );

  test(
    'an old blank cycle profile cannot block an existing cloud profile',
    () async {
      final db = LocalDatabase.forTesting(
        NativeDatabase.memory(),
        syncEnabled: true,
      );
      addTearDown(db.close);
      final store = TodoSyncStore(
        db,
        SensitiveFieldCipher(const FlutterSecureStorage()),
      );
      await db.customStatement(
        'INSERT INTO local_cycle_profiles(id) VALUES(1)',
      );
      final operation =
          (await db
                  .customSelect(
                    "SELECT operation_id FROM todo_local_outbox WHERE entity='cycle_profiles'",
                  )
                  .getSingle())
              .read<String>('operation_id');
      await store.apply({
        'accepted': [],
        'conflicts': [
          {
            'entity': 'cycle_profiles',
            'key': '[1]',
            'operation_id': operation,
            'remote': {
              'revision': 2,
              'deleted': false,
              'payload': {
                'id': 1,
                'is_setup_complete': 1,
                'last_period_start_date': '2026-09-26',
              },
            },
          },
        ],
        'rows': [],
        'cursor': 2,
      });
      expect(await store.conflictCount(), 1);
      expect(await store.pending(), isEmpty);
      expect(await store.conflictCount(), 0);
      expect(await store.cursor(), 0);
      await store.apply({
        'accepted': [],
        'conflicts': [],
        'rows': [
          {
            'entity': 'cycle_profiles',
            'key': '[1]',
            'revision': 2,
            'deleted': false,
            'payload': {
              'id': 1,
              'is_setup_complete': 1,
              'last_period_start_date': '2026-09-26',
              'period_length_days': 5,
              'cycle_length_days': 28,
            },
          },
        ],
        'cursor': 2,
      });
      final profile = await db.select(db.localCycleProfiles).getSingle();
      expect(profile.isSetupComplete, isTrue);
      expect(
        await store.cipher.decrypt(profile.lastPeriodStartDate!),
        '2026-09-26',
      );
      expect(await store.pending(), isEmpty);
    },
  );

  test('a real local cycle setting stays in the outbox', () async {
    final db = LocalDatabase.forTesting(
      NativeDatabase.memory(),
      syncEnabled: true,
    );
    addTearDown(db.close);
    final store = TodoSyncStore(
      db,
      SensitiveFieldCipher(const FlutterSecureStorage()),
    );
    await db.customStatement(
      'INSERT INTO local_cycle_profiles(id,is_setup_complete,last_period_start_date) '
      'VALUES(1,1,?)',
      [await store.cipher.encrypt('2026-09-27')],
    );
    final changes = await store.pending();
    expect(changes, hasLength(1));
    expect(
      (changes.single['payload'] as Map)['last_period_start_date'],
      '2026-09-27',
    );
  });

  test(
    'remote parent edit updates its row without removing linked habits',
    () async {
      final db = LocalDatabase.forTesting(
        NativeDatabase.memory(),
        syncEnabled: true,
      );
      addTearDown(db.close);
      final store = TodoSyncStore(
        db,
        SensitiveFieldCipher(const FlutterSecureStorage()),
      );
      await db.customStatement(
        "INSERT INTO local_children(id,nickname) VALUES(1,'旧名')",
      );
      await db.customStatement(
        "INSERT INTO local_habits(id,child_id,name) VALUES(8,1,'阅读')",
      );
      final initial = await store.pending();
      await store.apply({
        'accepted': initial
            .map(
              (row) => {
                'entity': row['entity'],
                'key': row['key'],
                'operation_id': row['operation_id'],
                'revision': 1,
              },
            )
            .toList(),
        'conflicts': [],
        'rows': [],
        'cursor': 1,
      });
      final before =
          (await db
                  .customSelect(
                    'SELECT rowid AS row_key FROM local_children WHERE id=1',
                  )
                  .getSingle())
              .read<int>('row_key');
      await store.apply({
        'accepted': [],
        'conflicts': [],
        'rows': [
          {
            'entity': 'children',
            'key': '[1]',
            'payload': {'id': 1, 'nickname': '新名'},
            'revision': 2,
            'deleted': false,
          },
        ],
        'cursor': 2,
      });
      final after = (await db
          .customSelect(
            'SELECT rowid AS row_key, nickname FROM local_children WHERE id=1',
          )
          .getSingle());
      expect(after.read<int>('row_key'), before);
      expect(after.read<String>('nickname'), '新名');
      expect(
        (await db
                .customSelect('SELECT child_id FROM local_habits WHERE id=8')
                .getSingle())
            .read<int>('child_id'),
        1,
      );
    },
  );

  test('deletion leaves a tombstone that removes a remote copy', () async {
    final left = LocalDatabase.forTesting(
      NativeDatabase.memory(),
      syncEnabled: true,
    );
    final right = LocalDatabase.forTesting(
      NativeDatabase.memory(),
      syncEnabled: true,
    );
    addTearDown(left.close);
    addTearDown(right.close);
    final source = TodoSyncStore(
      left,
      SensitiveFieldCipher(const FlutterSecureStorage()),
    );
    final target = TodoSyncStore(
      right,
      SensitiveFieldCipher(const FlutterSecureStorage()),
    );
    await left.customStatement(
      "INSERT INTO local_habits(id,child_id,name) VALUES(81,1,'阅读')",
    );
    await right.customStatement(
      "INSERT INTO local_habits(id,child_id,name) VALUES(81,1,'阅读')",
    );
    final key = (await source.pending()).single['key'];
    await left.customStatement('DELETE FROM local_habits WHERE id=81');
    final deleted = (await source.pending()).single;
    expect(deleted['deleted'], true);
    await target.apply({
      'accepted': [],
      'conflicts': [],
      'rows': [
        {
          'entity': 'habits',
          'key': key,
          'payload': deleted['payload'],
          'deleted': true,
          'revision': 2,
        },
      ],
      'cursor': 2,
    });
    // The other phone still has an unuploaded insert, so a remote tombstone
    // cannot silently erase it; it remains pending for an explicit conflict.
    expect(
      (await right
              .customSelect('SELECT count(*) AS n FROM local_habits')
              .getSingle())
          .read<int>('n'),
      1,
    );
    await target.apply({
      'accepted': [],
      'conflicts': [
        {
          'entity': 'habits',
          'key': key,
          'operation_id': (await target.pending()).single['operation_id'],
          'remote': {
            'revision': 2,
            'payload': deleted['payload'],
            'deleted': true,
          },
        },
      ],
      'rows': [],
      'cursor': 2,
    });
    await target.resolveConflicts(keepLocal: false);
    expect(
      (await right
              .customSelect('SELECT count(*) AS n FROM local_habits')
              .getSingle())
          .read<int>('n'),
      0,
    );
  });
}

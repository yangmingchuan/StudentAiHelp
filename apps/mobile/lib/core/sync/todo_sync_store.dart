import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:little_hero/core/security/sensitive_field_cipher.dart';

class SyncEntity {
  const SyncEntity(
    this.name,
    this.keys, {
    this.omitId = false,
    this.secret = const [],
  });
  final String name;
  final List<String> keys;
  final bool omitId;
  final List<String> secret;
  String get table => 'local_$name';
}

const syncEntities = [
  SyncEntity('children', ['id']),
  SyncEntity('habits', ['id']),
  SyncEntity('habit_records', [
    'child_id',
    'habit_id',
    'record_date',
  ], omitId: true),
  SyncEntity('child_badges', ['child_id', 'code']),
  SyncEntity('daily_awards', [
    'child_id',
    'award_date',
    'award_type',
  ], omitId: true),
  SyncEntity('rest_days', ['child_id', 'rest_date']),
  SyncEntity('rewards', ['id']),
  SyncEntity('reward_redemptions', ['id']),
  SyncEntity(
    'cycle_profiles',
    ['id'],
    secret: ['last_period_start_date', 'birth_date'],
  ),
  SyncEntity(
    'cycle_day_logs',
    ['log_date'],
    secret: ['diary_text', 'symptoms_json'],
  ),
  SyncEntity(
    'medication_members',
    ['id'],
    secret: ['allergy_note', 'condition_note'],
  ),
  SyncEntity('medicines', ['id'], secret: ['default_dosage', 'usage_note']),
  SyncEntity(
    'medication_logs',
    ['id'],
    secret: ['dosage_text', 'reason', 'note', 'void_reason'],
  ),
  SyncEntity('medication_reminders', ['id'], secret: ['dosage_text']),
];

/// SQLite triggers make the outbox atomic with every repository write, including
/// edits made while offline. Incoming rows suppress triggers in the same transaction.
class TodoSyncStore {
  TodoSyncStore(this.db, this.cipher);
  final GeneratedDatabase db;
  final SensitiveFieldCipher cipher;

  static Future<void> install(GeneratedDatabase db) async {
    await db.customStatement(
      'CREATE TABLE IF NOT EXISTS todo_local_meta (key TEXT PRIMARY KEY, value TEXT NOT NULL)',
    );
    await db.customStatement(
      "INSERT OR IGNORE INTO todo_local_meta VALUES ('applying','0'),('cursor','0')",
    );
    await db.customStatement('''CREATE TABLE IF NOT EXISTS todo_local_versions (
      entity TEXT NOT NULL, record_key TEXT NOT NULL, revision INTEGER NOT NULL,
      PRIMARY KEY(entity,record_key))''');
    await db.customStatement('''CREATE TABLE IF NOT EXISTS todo_local_outbox (
      entity TEXT NOT NULL, record_key TEXT NOT NULL, payload TEXT NOT NULL,
      deleted INTEGER NOT NULL, operation_id TEXT NOT NULL, conflict TEXT,
      PRIMARY KEY(entity,record_key))''');
    for (final entity in syncEntities) {
      final table = db.allTables.firstWhere(
        (t) => t.actualTableName == entity.table,
      );
      final columns = table.$columns
          .map((c) => c.$name)
          .where(
            (name) =>
                !['is_dirty', 'operation_id', 'updated_at'].contains(name) &&
                !(entity.omitId && name == 'id'),
          )
          .toList();
      for (final event in ['INSERT', 'UPDATE', 'DELETE']) {
        final row = event == 'DELETE' ? 'OLD' : 'NEW';
        final key =
            'json_array(${entity.keys.map((k) => '$row."$k"').join(',')})';
        final payload =
            'json_object(${columns.map((c) => "'$c',$row.\"$c\"").join(',')})';
        await db.customStatement(
          '''CREATE TRIGGER IF NOT EXISTS todo_capture_${entity.name}_${event.toLowerCase()}
          AFTER $event ON ${entity.table}
          WHEN (SELECT value FROM todo_local_meta WHERE key='applying')='0'
          BEGIN
            INSERT INTO todo_local_outbox(entity,record_key,payload,deleted,operation_id)
            VALUES('${entity.name}',$key,$payload,${event == 'DELETE' ? 1 : 0},lower(hex(randomblob(16))))
            ON CONFLICT(entity,record_key) DO UPDATE SET payload=excluded.payload,
              deleted=excluded.deleted,operation_id=excluded.operation_id,conflict=NULL;
          END''',
        );
      }
    }
    final installed = await db
        .customSelect("SELECT value FROM todo_local_meta WHERE key='seeded'")
        .get();
    if (installed.isEmpty) {
      // Capture existing imported rows once; subsequent opens never re-upload a snapshot.
      for (final entity in syncEntities) {
        final key = entity.keys.first;
        await db.customStatement('UPDATE ${entity.table} SET "$key"="$key"');
      }
      await db.customStatement(
        "INSERT INTO todo_local_meta VALUES('seeded','1')",
      );
    }
  }

  Future<int> cursor() async => int.parse(
    (await db
            .customSelect(
              "SELECT value FROM todo_local_meta WHERE key='cursor'",
            )
            .getSingle())
        .read<String>('value'),
  );

  Future<List<Map<String, dynamic>>> pending() async {
    await _discardPristineCyclePlaceholder();
    final rows = await db.customSelect(
      '''SELECT o.*,coalesce(v.revision,0) AS base_revision
      FROM todo_local_outbox o LEFT JOIN todo_local_versions v
      ON o.entity=v.entity AND o.record_key=v.record_key WHERE o.conflict IS NULL LIMIT 200''',
    ).get();
    final changes = <Map<String, dynamic>>[];
    for (final row in rows) {
      final entity = syncEntities.firstWhere(
        (e) => e.name == row.read<String>('entity'),
      );
      final payload = Map<String, dynamic>.from(
        jsonDecode(row.read<String>('payload')) as Map,
      );
      for (final field in entity.secret) {
        if (payload[field] is String) {
          payload[field] = await cipher.decryptStrict(payload[field] as String);
        }
      }
      changes.add({
        'entity': entity.name,
        'key': row.read<String>('record_key'),
        'payload': payload,
        'deleted': row.read<int>('deleted') == 1,
        'operation_id': row.read<String>('operation_id'),
        'base_revision': row.read<int>('base_revision'),
      });
    }
    return changes;
  }

  // Older builds inserted a blank cycle profile merely by opening the page.
  // That row could conflict with an already configured profile on another phone,
  // and the incoming profile would then be skipped as the cursor advanced.
  // A genuinely configured profile (including any date) must never be discarded.
  Future<void> _discardPristineCyclePlaceholder() async {
    final candidates = await db
        .customSelect(
          "SELECT payload, operation_id FROM todo_local_outbox "
          "WHERE entity='cycle_profiles' AND record_key='[1]' AND deleted=0",
        )
        .get();
    if (candidates.isEmpty) return;
    final payload =
        jsonDecode(candidates.single.read<String>('payload')) as Map;
    if (payload['is_setup_complete'] == 1 ||
        payload['is_setup_complete'] == true ||
        payload['last_period_start_date'] != null ||
        payload['birth_date'] != null ||
        payload['period_length_days'] != 5 ||
        payload['cycle_length_days'] != 28 ||
        payload['cloud_sync_enabled'] == 1 ||
        payload['cloud_sync_enabled'] == true) {
      return;
    }
    final current = await db
        .customSelect(
          'SELECT is_setup_complete, last_period_start_date, birth_date, '
          'period_length_days, cycle_length_days, cloud_sync_enabled '
          'FROM local_cycle_profiles WHERE id=1',
        )
        .getSingleOrNull();
    if (current == null ||
        current.read<int>('is_setup_complete') != 0 ||
        current.readNullable<String>('last_period_start_date') != null ||
        current.readNullable<String>('birth_date') != null ||
        current.read<int>('period_length_days') != 5 ||
        current.read<int>('cycle_length_days') != 28 ||
        current.read<int>('cloud_sync_enabled') != 0) {
      return;
    }
    await db.transaction(() async {
      await db.customStatement(
        "DELETE FROM todo_local_outbox WHERE entity='cycle_profiles' "
        'AND record_key=\'[1]\' AND operation_id=?',
        [candidates.single.read<String>('operation_id')],
      );
      // A previous pull may have skipped the cloud row while this outbox item
      // existed. Replay it so the configured remote profile can now apply.
      await db.customStatement(
        "UPDATE todo_local_meta SET value='0' WHERE key='cursor'",
      );
    });
  }

  Future<int> conflictCount() async =>
      (await db
              .customSelect(
                'SELECT count(*) AS n FROM todo_local_outbox WHERE conflict IS NOT NULL',
              )
              .getSingle())
          .read<int>('n');

  Future<bool> apply(Map<String, dynamic> response) async {
    if ((response['accepted'] as List).isEmpty &&
        (response['conflicts'] as List).isEmpty &&
        (response['rows'] as List).isEmpty &&
        response['cursor'] == await cursor()) {
      return false;
    }
    var changed = false;
    await db.transaction(() async {
      await db.customStatement(
        "UPDATE todo_local_meta SET value='1' WHERE key='applying'",
      );
      for (final raw in response['accepted'] as List) {
        final item = Map<String, dynamic>.from(raw as Map);
        await _version(item);
        await db.customStatement(
          'DELETE FROM todo_local_outbox WHERE entity=? AND record_key=? AND operation_id=?',
          [item['entity'], item['key'], item['operation_id']],
        );
      }
      for (final raw in response['conflicts'] as List) {
        final item = Map<String, dynamic>.from(raw as Map);
        // Store conflict health text encrypted too, never plaintext in SQLite.
        final remote = Map<String, dynamic>.from(item['remote'] as Map);
        final entity = syncEntities.firstWhere((e) => e.name == item['entity']);
        remote['payload'] = await _protect(
          entity,
          Map<String, dynamic>.from(remote['payload'] as Map),
        );
        await db.customStatement(
          'UPDATE todo_local_outbox SET conflict=? WHERE entity=? AND record_key=? AND operation_id=?',
          [
            jsonEncode(remote),
            item['entity'],
            item['key'],
            item['operation_id'],
          ],
        );
      }
      for (final raw in response['rows'] as List) {
        final item = Map<String, dynamic>.from(raw as Map);
        final entity = syncEntities.firstWhere((e) => e.name == item['entity']);
        final pending = await db
            .customSelect(
              'SELECT operation_id FROM todo_local_outbox WHERE entity=? AND record_key=?',
              variables: [
                Variable(item['entity'] as String),
                Variable(item['key'] as String),
              ],
            )
            .get();
        if (pending.isNotEmpty) {
          continue; // Preserve edits made during the network request.
        }
        await _version(item);
        await _replace(
          entity,
          item['key'] as String,
          Map<String, dynamic>.from(item['payload'] as Map),
          item['deleted'] == true,
        );
        changed = true;
      }
      await db.customStatement(
        "UPDATE todo_local_meta SET value=? WHERE key='cursor'",
        [response['cursor'].toString()],
      );
      await _recomputeAssets();
      await db.customStatement(
        "UPDATE todo_local_meta SET value='0' WHERE key='applying'",
      );
    });
    return changed;
  }

  Future<Map<String, dynamic>> _protect(
    SyncEntity entity,
    Map<String, dynamic> payload,
  ) async {
    final result = Map<String, dynamic>.from(payload);
    for (final field in entity.secret) {
      if (result[field] is String) {
        result[field] = await cipher.encrypt(result[field] as String);
      }
    }
    return result;
  }

  Future<void> _version(Map<String, dynamic> item) => db.customStatement(
    '''INSERT INTO todo_local_versions VALUES(?,?,?)
    ON CONFLICT(entity,record_key) DO UPDATE SET revision=max(revision,excluded.revision)''',
    [item['entity'], item['key'], item['revision']],
  );

  Future<void> _replace(
    SyncEntity entity,
    String key,
    Map<String, dynamic> payload,
    bool deleted,
  ) async {
    final values = jsonDecode(key) as List;
    final where = entity.keys.map((k) => '"$k"=?').join(' AND ');
    if (deleted || entity.omitId) {
      await db.customStatement(
        'DELETE FROM ${entity.table} WHERE $where',
        values,
      );
      if (deleted) return;
    }
    final table = db.allTables.firstWhere(
      (t) => t.actualTableName == entity.table,
    );
    final allowed = table.$columns.map((c) => c.$name).toSet();
    final protected = await _protect(entity, payload);
    final entries = protected.entries
        .where(
          (e) => allowed.contains(e.key) && !(entity.omitId && e.key == 'id'),
        )
        .toList();
    final columns = entries.map((e) => '"${e.key}"').join(',');
    final placeholders = entries.map((_) => '?').join(',');
    final update = entries
        .where((e) => !entity.keys.contains(e.key))
        .map((e) => '"${e.key}"=excluded."${e.key}"')
        .join(',');
    await db.customStatement(
      'INSERT INTO ${entity.table} ($columns) VALUES ($placeholders)'
      '${entity.omitId ? '' : ' ON CONFLICT(${entity.keys.map((k) => '"$k"').join(',')}) DO UPDATE SET $update'}',
      entries.map((e) => e.value).toList(),
    );
  }

  Future<void> resolveConflicts({required bool keepLocal}) async {
    await db.transaction(() async {
      await db.customStatement(
        "UPDATE todo_local_meta SET value='1' WHERE key='applying'",
      );
      final rows = await db
          .customSelect(
            'SELECT * FROM todo_local_outbox WHERE conflict IS NOT NULL',
          )
          .get();
      for (final row in rows) {
        final entity = syncEntities.firstWhere(
          (e) => e.name == row.read<String>('entity'),
        );
        final key = row.read<String>('record_key');
        final remote = Map<String, dynamic>.from(
          jsonDecode(row.read<String>('conflict')) as Map,
        );
        await _version({
          'entity': entity.name,
          'key': key,
          'revision': remote['revision'],
        });
        if (keepLocal) {
          await db.customStatement(
            'UPDATE todo_local_outbox SET conflict=NULL,operation_id=lower(hex(randomblob(16))) WHERE entity=? AND record_key=?',
            [entity.name, key],
          );
        } else {
          await _replace(
            entity,
            key,
            Map<String, dynamic>.from(remote['payload'] as Map),
            remote['deleted'] == true,
          );
          await db.customStatement(
            'DELETE FROM todo_local_outbox WHERE entity=? AND record_key=?',
            [entity.name, key],
          );
        }
      }
      await _recomputeAssets();
      await db.customStatement(
        "UPDATE todo_local_meta SET value='0' WHERE key='applying'",
      );
    });
  }

  Future<void> _recomputeAssets() async {
    // Derive balances from merged records, never merge two cached balances.
    await db.customStatement(
      '''INSERT INTO local_asset_snapshots(child_id,available_stars,lifetime_stars,badge_count,hearts_remaining,hearts_limit,snapshot_date)
      SELECT c.id,
        (SELECT count(*) FROM local_habit_records r WHERE r.child_id=c.id AND r.status='done')+
        coalesce((SELECT sum(stars) FROM local_daily_awards a WHERE a.child_id=c.id),0)-
        coalesce((SELECT sum(cost_stars) FROM local_reward_redemptions x WHERE x.child_id=c.id AND x.status IN ('pending','approved')),0),
        (SELECT count(*) FROM local_habit_records r WHERE r.child_id=c.id AND r.status='done')+
        coalesce((SELECT sum(stars) FROM local_daily_awards a WHERE a.child_id=c.id),0),
        (SELECT count(*) FROM local_child_badges b WHERE b.child_id=c.id),10,10,date('now','localtime')
      FROM local_children c WHERE true
      ON CONFLICT(child_id) DO UPDATE SET available_stars=excluded.available_stars,lifetime_stars=excluded.lifetime_stars,badge_count=excluded.badge_count''',
    );
  }
}

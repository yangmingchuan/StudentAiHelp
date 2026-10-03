import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:little_hero/core/database/local_database.dart';
import 'package:little_hero/core/security/sensitive_field_cipher.dart';
import 'package:little_hero/core/sync/todo_sync_store.dart';
import 'package:little_hero/features/medication/data/medication_repository.dart';
import 'package:little_hero/features/medication/domain/medication_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test('deleted logs and reminders disappear and sync as deletions', () async {
    final db = LocalDatabase.forTesting(
      NativeDatabase.memory(),
      syncEnabled: true,
    );
    addTearDown(db.close);
    final cipher = SensitiveFieldCipher(const FlutterSecureStorage());
    final repository = MedicationRepository(db, cipher);
    final reminder = await repository.addLog(
      MedicationLogDraft(
        memberId: null,
        medicineId: null,
        memberName: '孩子',
        medicineName: '药品',
        takenAt: DateTime.now(),
        dosageText: '一次',
        reason: '',
        note: '',
        nextReminderAt: DateTime.now().add(const Duration(days: 1)),
      ),
    );
    final logId = (await repository.load()).logs.single.id;

    expect(await repository.deleteLog(logId), [reminder!.id]);
    final snapshot = await repository.load();
    expect(snapshot.logs, isEmpty);
    expect(snapshot.todayLogCount, 0);
    expect(snapshot.upcomingReminders, isEmpty);
    expect(await db.select(db.localMedicationLogs).get(), isEmpty);
    expect(await db.select(db.localMedicationReminders).get(), isEmpty);

    final pending = await TodoSyncStore(db, cipher).pending();
    expect(
      pending
          .where((change) => change['entity'] == 'medication_logs')
          .single['deleted'],
      isTrue,
    );
    expect(
      pending
          .where((change) => change['entity'] == 'medication_reminders')
          .single['deleted'],
      isTrue,
    );
  });

  test(
    'previously voided and corrected records are absent from the list',
    () async {
      final db = LocalDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      final repository = MedicationRepository(
        db,
        SensitiveFieldCipher(const FlutterSecureStorage()),
      );
      MedicationLogDraft draft(String medicine) => MedicationLogDraft(
        memberId: null,
        medicineId: null,
        memberName: '孩子',
        medicineName: medicine,
        takenAt: DateTime.now(),
        dosageText: '',
        reason: '',
        note: '',
        nextReminderAt: null,
      );
      await repository.addLog(draft('旧记录'));
      final originalId = (await repository.load()).logs.single.id;
      await repository.amendLog(originalLogId: originalId, draft: draft('更正后'));

      final snapshot = await repository.load();
      expect(snapshot.logs.map((log) => log.medicineName), ['更正后']);
      expect(await db.select(db.localMedicationLogs).get(), hasLength(2));
    },
  );
}

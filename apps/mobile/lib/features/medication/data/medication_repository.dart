import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:little_hero/core/database/local_database.dart';
import 'package:little_hero/core/security/sensitive_field_cipher.dart';
import 'package:little_hero/features/medication/domain/medication_models.dart';

final medicationRepositoryProvider = Provider<MedicationRepository>((ref) {
  return MedicationRepository(
    ref.watch(localDatabaseProvider),
    ref.watch(sensitiveFieldCipherProvider),
  );
});

class MedicationRepository {
  const MedicationRepository(this._db, this._cipher);

  final LocalDatabase _db;
  final SensitiveFieldCipher _cipher;

  Future<MedicationSnapshot> load() async {
    final memberRows =
        await (_db.select(_db.localMedicationMembers)..orderBy([
              (table) => OrderingTerm.desc(table.updatedAt),
              (table) => OrderingTerm.asc(table.id),
            ]))
            .get();
    final medicineRows =
        await (_db.select(_db.localMedicines)..orderBy([
              (table) => OrderingTerm.asc(table.expiresOn),
              (table) => OrderingTerm.desc(table.updatedAt),
            ]))
            .get();
    final logRows =
        await (_db.select(_db.localMedicationLogs)
              ..orderBy([(table) => OrderingTerm.desc(table.takenAt)])
              ..limit(50))
            .get();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final medicines = await Future.wait(medicineRows.map(_toMedicine));
    final logs = await Future.wait(logRows.map(_toLog));
    final reminderRows =
        await (_db.select(_db.localMedicationReminders)
              ..where(
                (table) =>
                    table.status.equals(
                      MedicationReminderStatus.scheduled.value,
                    ) &
                    table.remindAt.isBiggerOrEqualValue(now),
              )
              ..orderBy([(table) => OrderingTerm.asc(table.remindAt)]))
            .get();
    final upcomingReminders = await Future.wait(reminderRows.map(_toReminder));

    return MedicationSnapshot(
      members: await Future.wait(memberRows.map(_toMember)),
      medicines: medicines,
      logs: logs,
      upcomingReminders: upcomingReminders.take(3).toList(),
      todayLogCount: logs
          .where((log) => !log.isVoided && _isSameDay(log.takenAt, today))
          .length,
      expiringSoonCount: medicines.where((medicine) {
        return medicine.expiryStatus == MedicineExpiryStatus.expiringSoon;
      }).length,
      expiredCount: medicines.where((medicine) {
        return medicine.expiryStatus == MedicineExpiryStatus.expired;
      }).length,
    );
  }

  Future<void> addMember(MedicationMemberDraft draft) async {
    final name = draft.name.trim();
    if (name.isEmpty) {
      throw ArgumentError('请填写成员姓名');
    }
    final now = DateTime.now();
    await _db
        .into(_db.localMedicationMembers)
        .insert(
          LocalMedicationMembersCompanion.insert(
            name: name,
            relation: Value(_blankAsDefault(draft.relation, '家庭成员')),
            ageNote: Value(draft.ageNote.trim()),
            allergyNote: Value(await _cipher.encrypt(draft.allergyNote.trim())),
            conditionNote: Value(
              await _cipher.encrypt(draft.conditionNote.trim()),
            ),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );
  }

  Future<void> addMedicine(MedicineDraft draft) async {
    final name = draft.name.trim();
    if (name.isEmpty) {
      throw ArgumentError('请填写药品名称');
    }
    final now = DateTime.now();
    await _db
        .into(_db.localMedicines)
        .insert(
          LocalMedicinesCompanion.insert(
            name: name,
            specification: Value(draft.specification.trim()),
            defaultDosage: Value(
              await _cipher.encrypt(draft.defaultDosage.trim()),
            ),
            storageLocation: Value(draft.storageLocation.trim()),
            expiresOn: Value(_formatDateOrNull(draft.expiresOn)),
            stockNote: Value(draft.stockNote.trim()),
            usageNote: Value(await _cipher.encrypt(draft.usageNote.trim())),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );
  }

  Future<MedicationReminder?> addLog(MedicationLogDraft draft) async {
    _validateLogDraft(draft);
    return _db.transaction(() async {
      final logId = await _insertLog(draft);
      return _createReminder(draft, sourceLogId: logId);
    });
  }

  Future<MedicationLogMutation> amendLog({
    required int originalLogId,
    required MedicationLogDraft draft,
  }) async {
    _validateLogDraft(draft);
    return _db.transaction(() async {
      final original = await (_db.select(
        _db.localMedicationLogs,
      )..where((table) => table.id.equals(originalLogId))).getSingleOrNull();
      if (original == null || original.voidedAt != null) {
        throw ArgumentError('这条记录无法更正');
      }
      final newLogId = await _insertLog(draft);
      await (_db.update(
        _db.localMedicationLogs,
      )..where((table) => table.id.equals(originalLogId))).write(
        LocalMedicationLogsCompanion(
          voidedAt: Value(DateTime.now()),
          voidReason: const Value('已更正'),
          correctedByLogId: Value(newLogId),
        ),
      );
      final canceledReminderIds = await _cancelScheduledRemindersForLog(
        originalLogId,
      );
      final reminder = await _createReminder(draft, sourceLogId: newLogId);
      return MedicationLogMutation(
        reminder: reminder,
        canceledReminderIds: canceledReminderIds,
      );
    });
  }

  Future<List<int>> voidLog({
    required int logId,
    required String reason,
  }) async {
    final normalizedReason = reason.trim().isEmpty ? '用户作废' : reason.trim();
    final changed =
        await (_db.update(_db.localMedicationLogs)..where(
              (table) => table.id.equals(logId) & table.voidedAt.isNull(),
            ))
            .write(
              LocalMedicationLogsCompanion(
                voidedAt: Value(DateTime.now()),
                voidReason: Value(normalizedReason),
              ),
            );
    if (changed == 0) throw ArgumentError('这条记录已作废或不存在');
    return _cancelScheduledRemindersForLog(logId);
  }

  Future<void> resolveReminder({
    required int reminderId,
    required MedicationReminderStatus status,
  }) async {
    if (status == MedicationReminderStatus.scheduled) {
      throw ArgumentError('请选择完成、跳过或取消提醒');
    }
    final changed =
        await (_db.update(_db.localMedicationReminders)..where(
              (table) =>
                  table.id.equals(reminderId) &
                  table.status.equals(MedicationReminderStatus.scheduled.value),
            ))
            .write(
              LocalMedicationRemindersCompanion(
                status: Value(status.value),
                resolvedAt: Value(DateTime.now()),
                updatedAt: Value(DateTime.now()),
              ),
            );
    if (changed == 0) throw ArgumentError('这条提醒已处理或不存在');
  }

  Future<List<int>> _cancelScheduledRemindersForLog(int sourceLogId) async {
    final reminders =
        await (_db.select(_db.localMedicationReminders)..where(
              (table) =>
                  table.sourceLogId.equals(sourceLogId) &
                  table.status.equals(MedicationReminderStatus.scheduled.value),
            ))
            .get();
    if (reminders.isEmpty) return const [];
    final ids = reminders.map((item) => item.id).toList(growable: false);
    await (_db.update(
      _db.localMedicationReminders,
    )..where((table) => table.id.isIn(ids))).write(
      LocalMedicationRemindersCompanion(
        status: const Value('canceled'),
        resolvedAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );
    return ids;
  }

  Future<int> _insertLog(MedicationLogDraft draft) async {
    final memberName = draft.memberName.trim();
    final medicineName = draft.medicineName.trim();
    return _db
        .into(_db.localMedicationLogs)
        .insert(
          LocalMedicationLogsCompanion.insert(
            memberId: Value(draft.memberId),
            medicineId: Value(draft.medicineId),
            memberName: memberName,
            medicineName: medicineName,
            takenAt: draft.takenAt,
            dosageText: Value(await _cipher.encrypt(draft.dosageText.trim())),
            reason: Value(await _cipher.encrypt(draft.reason.trim())),
            note: Value(await _cipher.encrypt(draft.note.trim())),
            nextReminderAt: Value(draft.nextReminderAt),
            createdAt: Value(DateTime.now()),
          ),
        );
  }

  Future<MedicationReminder?> _createReminder(
    MedicationLogDraft draft, {
    required int sourceLogId,
  }) async {
    final remindAt = draft.nextReminderAt;
    if (remindAt == null) return null;
    if (!remindAt.isAfter(DateTime.now())) {
      throw ArgumentError('下次提醒需要晚于当前时间');
    }
    final id = await _db
        .into(_db.localMedicationReminders)
        .insert(
          LocalMedicationRemindersCompanion.insert(
            memberId: Value(draft.memberId),
            medicineId: Value(draft.medicineId),
            sourceLogId: Value(sourceLogId),
            memberName: draft.memberName.trim(),
            medicineName: draft.medicineName.trim(),
            remindAt: remindAt,
            dosageText: Value(await _cipher.encrypt(draft.dosageText.trim())),
            createdAt: Value(DateTime.now()),
            updatedAt: Value(DateTime.now()),
          ),
        );
    return MedicationReminder(
      id: id,
      memberName: draft.memberName.trim(),
      medicineName: draft.medicineName.trim(),
      remindAt: remindAt,
      dosageText: draft.dosageText.trim(),
      status: MedicationReminderStatus.scheduled,
      sourceLogId: sourceLogId,
    );
  }

  void _validateLogDraft(MedicationLogDraft draft) {
    if (draft.memberName.trim().isEmpty) {
      throw ArgumentError('请填写用药成员');
    }
    if (draft.medicineName.trim().isEmpty) {
      throw ArgumentError('请填写药品名称');
    }
  }

  Future<MedicationMember> _toMember(LocalMedicationMember row) async {
    final allergyNote = await _readAndMigrateMemberField(
      row.id,
      row.allergyNote,
      isAllergy: true,
    );
    final conditionNote = await _readAndMigrateMemberField(
      row.id,
      row.conditionNote,
      isAllergy: false,
    );
    return MedicationMember(
      id: row.id,
      name: row.name,
      relation: row.relation,
      ageNote: row.ageNote,
      allergyNote: allergyNote,
      conditionNote: conditionNote,
    );
  }

  Future<MedicineItem> _toMedicine(LocalMedicine row) async {
    final dosage = await _readAndMigrateMedicineField(
      row.id,
      row.defaultDosage,
      isDosage: true,
    );
    final usageNote = await _readAndMigrateMedicineField(
      row.id,
      row.usageNote,
      isDosage: false,
    );
    return MedicineItem(
      id: row.id,
      name: row.name,
      specification: row.specification,
      defaultDosage: dosage,
      storageLocation: row.storageLocation,
      expiresOn: _parseDate(row.expiresOn),
      stockNote: row.stockNote,
      usageNote: usageNote,
      expiryStatus: _expiryStatus(_parseDate(row.expiresOn), DateTime.now()),
    );
  }

  Future<MedicationLogEntry> _toLog(LocalMedicationLog row) async {
    final dosage = await _readAndMigrateLogField(row.id, row.dosageText, 0);
    final reason = await _readAndMigrateLogField(row.id, row.reason, 1);
    final note = await _readAndMigrateLogField(row.id, row.note, 2);
    return MedicationLogEntry(
      id: row.id,
      memberName: row.memberName,
      medicineName: row.medicineName,
      takenAt: row.takenAt,
      dosageText: dosage,
      reason: reason,
      note: note,
      nextReminderAt: row.nextReminderAt,
      voidedAt: row.voidedAt,
      voidReason: row.voidReason,
      correctedByLogId: row.correctedByLogId,
    );
  }

  Future<MedicationReminder> _toReminder(LocalMedicationReminder row) async {
    final dosage = await _readAndMigrateReminderDosage(row);
    return MedicationReminder(
      id: row.id,
      memberName: row.memberName,
      medicineName: row.medicineName,
      remindAt: row.remindAt,
      dosageText: dosage,
      status: MedicationReminderStatus.parse(row.status),
      sourceLogId: row.sourceLogId,
    );
  }

  Future<String> _readAndMigrateMemberField(
    int id,
    String value, {
    required bool isAllergy,
  }) async {
    final clear = await _cipher.decrypt(value);
    if (value.isNotEmpty && !_cipher.isProtected(value)) {
      await (_db.update(
        _db.localMedicationMembers,
      )..where((table) => table.id.equals(id))).write(
        LocalMedicationMembersCompanion(
          allergyNote: isAllergy
              ? Value(await _cipher.encrypt(value))
              : const Value.absent(),
          conditionNote: isAllergy
              ? const Value.absent()
              : Value(await _cipher.encrypt(value)),
          updatedAt: Value(DateTime.now()),
        ),
      );
    }
    return clear;
  }

  Future<String> _readAndMigrateMedicineField(
    int id,
    String value, {
    required bool isDosage,
  }) async {
    final clear = await _cipher.decrypt(value);
    if (value.isNotEmpty && !_cipher.isProtected(value)) {
      await (_db.update(
        _db.localMedicines,
      )..where((table) => table.id.equals(id))).write(
        LocalMedicinesCompanion(
          defaultDosage: isDosage
              ? Value(await _cipher.encrypt(value))
              : const Value.absent(),
          usageNote: isDosage
              ? const Value.absent()
              : Value(await _cipher.encrypt(value)),
          updatedAt: Value(DateTime.now()),
        ),
      );
    }
    return clear;
  }

  Future<String> _readAndMigrateLogField(
    int id,
    String value,
    int field,
  ) async {
    final clear = await _cipher.decrypt(value);
    if (value.isNotEmpty && !_cipher.isProtected(value)) {
      await (_db.update(
        _db.localMedicationLogs,
      )..where((table) => table.id.equals(id))).write(
        LocalMedicationLogsCompanion(
          dosageText: field == 0
              ? Value(await _cipher.encrypt(value))
              : const Value.absent(),
          reason: field == 1
              ? Value(await _cipher.encrypt(value))
              : const Value.absent(),
          note: field == 2
              ? Value(await _cipher.encrypt(value))
              : const Value.absent(),
        ),
      );
    }
    return clear;
  }

  Future<String> _readAndMigrateReminderDosage(
    LocalMedicationReminder row,
  ) async {
    final clear = await _cipher.decrypt(row.dosageText);
    if (row.dosageText.isNotEmpty && !_cipher.isProtected(row.dosageText)) {
      await (_db.update(
        _db.localMedicationReminders,
      )..where((table) => table.id.equals(row.id))).write(
        LocalMedicationRemindersCompanion(
          dosageText: Value(await _cipher.encrypt(row.dosageText)),
          updatedAt: Value(DateTime.now()),
        ),
      );
    }
    return clear;
  }

  MedicineExpiryStatus _expiryStatus(DateTime? expiresOn, DateTime today) {
    if (expiresOn == null) {
      return MedicineExpiryStatus.unknown;
    }
    final date = DateTime(expiresOn.year, expiresOn.month, expiresOn.day);
    if (date.isBefore(today)) {
      return MedicineExpiryStatus.expired;
    }
    if (date.difference(today).inDays <= 30) {
      return MedicineExpiryStatus.expiringSoon;
    }
    return MedicineExpiryStatus.ok;
  }

  DateTime? _parseDate(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }

  String? _formatDateOrNull(DateTime? date) {
    if (date == null) {
      return null;
    }
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  bool _isSameDay(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }

  String _blankAsDefault(String value, String fallback) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? fallback : trimmed;
  }
}

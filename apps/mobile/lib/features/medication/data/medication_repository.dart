import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:little_hero/core/database/local_database.dart';
import 'package:little_hero/features/medication/domain/medication_models.dart';

final medicationRepositoryProvider = Provider<MedicationRepository>((ref) {
  return MedicationRepository(ref.watch(localDatabaseProvider));
});

class MedicationRepository {
  const MedicationRepository(this._db);

  final LocalDatabase _db;

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
    final medicines = [
      for (final row in medicineRows)
        MedicineItem(
          id: row.id,
          name: row.name,
          specification: row.specification,
          defaultDosage: row.defaultDosage,
          storageLocation: row.storageLocation,
          expiresOn: _parseDate(row.expiresOn),
          stockNote: row.stockNote,
          usageNote: row.usageNote,
          expiryStatus: _expiryStatus(_parseDate(row.expiresOn), today),
        ),
    ];
    final logs = [
      for (final row in logRows)
        MedicationLogEntry(
          id: row.id,
          memberName: row.memberName,
          medicineName: row.medicineName,
          takenAt: row.takenAt,
          dosageText: row.dosageText,
          reason: row.reason,
          note: row.note,
          nextReminderAt: row.nextReminderAt,
        ),
    ];
    final upcomingReminders =
        logs
            .where(
              (log) =>
                  log.nextReminderAt != null &&
                  !log.nextReminderAt!.isBefore(now),
            )
            .map(
              (log) => MedicationReminder(
                memberName: log.memberName,
                medicineName: log.medicineName,
                remindAt: log.nextReminderAt!,
                dosageText: log.dosageText,
              ),
            )
            .toList()
          ..sort((a, b) => a.remindAt.compareTo(b.remindAt));

    return MedicationSnapshot(
      members: [
        for (final row in memberRows)
          MedicationMember(
            id: row.id,
            name: row.name,
            relation: row.relation,
            ageNote: row.ageNote,
            allergyNote: row.allergyNote,
            conditionNote: row.conditionNote,
          ),
      ],
      medicines: medicines,
      logs: logs,
      upcomingReminders: upcomingReminders.take(3).toList(),
      todayLogCount: logs.where((log) => _isSameDay(log.takenAt, today)).length,
      expiringSoonCount: medicines.where((medicine) {
        return medicine.expiryStatus == MedicineExpiryStatus.expiringSoon;
      }).length,
      expiredCount: medicines.where((medicine) {
        return medicine.expiryStatus == MedicineExpiryStatus.expired;
      }).length,
    );
  }

  Future<void> addMember(MedicationMemberDraft draft) {
    final name = draft.name.trim();
    if (name.isEmpty) {
      throw ArgumentError('请填写成员姓名');
    }
    final now = DateTime.now();
    return _db
        .into(_db.localMedicationMembers)
        .insert(
          LocalMedicationMembersCompanion.insert(
            name: name,
            relation: Value(_blankAsDefault(draft.relation, '家庭成员')),
            ageNote: Value(draft.ageNote.trim()),
            allergyNote: Value(draft.allergyNote.trim()),
            conditionNote: Value(draft.conditionNote.trim()),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );
  }

  Future<void> addMedicine(MedicineDraft draft) {
    final name = draft.name.trim();
    if (name.isEmpty) {
      throw ArgumentError('请填写药品名称');
    }
    final now = DateTime.now();
    return _db
        .into(_db.localMedicines)
        .insert(
          LocalMedicinesCompanion.insert(
            name: name,
            specification: Value(draft.specification.trim()),
            defaultDosage: Value(draft.defaultDosage.trim()),
            storageLocation: Value(draft.storageLocation.trim()),
            expiresOn: Value(_formatDateOrNull(draft.expiresOn)),
            stockNote: Value(draft.stockNote.trim()),
            usageNote: Value(draft.usageNote.trim()),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );
  }

  Future<void> addLog(MedicationLogDraft draft) {
    final memberName = draft.memberName.trim();
    final medicineName = draft.medicineName.trim();
    if (memberName.isEmpty) {
      throw ArgumentError('请填写用药成员');
    }
    if (medicineName.isEmpty) {
      throw ArgumentError('请填写药品名称');
    }
    return _db
        .into(_db.localMedicationLogs)
        .insert(
          LocalMedicationLogsCompanion.insert(
            memberId: Value(draft.memberId),
            medicineId: Value(draft.medicineId),
            memberName: memberName,
            medicineName: medicineName,
            takenAt: draft.takenAt,
            dosageText: Value(draft.dosageText.trim()),
            reason: Value(draft.reason.trim()),
            note: Value(draft.note.trim()),
            nextReminderAt: Value(draft.nextReminderAt),
            createdAt: Value(DateTime.now()),
          ),
        );
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

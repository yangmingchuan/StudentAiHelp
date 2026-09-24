class MedicationMemberDraft {
  const MedicationMemberDraft({
    required this.name,
    required this.relation,
    required this.ageNote,
    required this.allergyNote,
    required this.conditionNote,
  });

  final String name;
  final String relation;
  final String ageNote;
  final String allergyNote;
  final String conditionNote;
}

class MedicineDraft {
  const MedicineDraft({
    required this.name,
    required this.specification,
    required this.defaultDosage,
    required this.storageLocation,
    required this.expiresOn,
    required this.stockNote,
    required this.usageNote,
  });

  final String name;
  final String specification;
  final String defaultDosage;
  final String storageLocation;
  final DateTime? expiresOn;
  final String stockNote;
  final String usageNote;
}

class MedicationLogDraft {
  const MedicationLogDraft({
    required this.memberId,
    required this.medicineId,
    required this.memberName,
    required this.medicineName,
    required this.takenAt,
    required this.dosageText,
    required this.reason,
    required this.note,
    required this.nextReminderAt,
  });

  final int? memberId;
  final int? medicineId;
  final String memberName;
  final String medicineName;
  final DateTime takenAt;
  final String dosageText;
  final String reason;
  final String note;
  final DateTime? nextReminderAt;
}

class MedicationSnapshot {
  const MedicationSnapshot({
    required this.members,
    required this.medicines,
    required this.logs,
    required this.upcomingReminders,
    required this.todayLogCount,
    required this.expiringSoonCount,
    required this.expiredCount,
  });

  final List<MedicationMember> members;
  final List<MedicineItem> medicines;
  final List<MedicationLogEntry> logs;
  final List<MedicationReminder> upcomingReminders;
  final int todayLogCount;
  final int expiringSoonCount;
  final int expiredCount;
}

class MedicationMember {
  const MedicationMember({
    required this.id,
    required this.name,
    required this.relation,
    required this.ageNote,
    required this.allergyNote,
    required this.conditionNote,
  });

  final int id;
  final String name;
  final String relation;
  final String ageNote;
  final String allergyNote;
  final String conditionNote;

  String get subtitle {
    final parts = [
      if (relation.isNotEmpty) relation,
      if (ageNote.isNotEmpty) ageNote,
    ];
    return parts.isEmpty ? '家庭成员' : parts.join(' · ');
  }
}

class MedicineItem {
  const MedicineItem({
    required this.id,
    required this.name,
    required this.specification,
    required this.defaultDosage,
    required this.storageLocation,
    required this.expiresOn,
    required this.stockNote,
    required this.usageNote,
    required this.expiryStatus,
  });

  final int id;
  final String name;
  final String specification;
  final String defaultDosage;
  final String storageLocation;
  final DateTime? expiresOn;
  final String stockNote;
  final String usageNote;
  final MedicineExpiryStatus expiryStatus;
}

class MedicationLogEntry {
  const MedicationLogEntry({
    required this.id,
    required this.memberName,
    required this.medicineName,
    required this.takenAt,
    required this.dosageText,
    required this.reason,
    required this.note,
    required this.nextReminderAt,
    required this.voidedAt,
    required this.voidReason,
    required this.correctedByLogId,
  });

  final int id;
  final String memberName;
  final String medicineName;
  final DateTime takenAt;
  final String dosageText;
  final String reason;
  final String note;
  final DateTime? nextReminderAt;
  final DateTime? voidedAt;
  final String voidReason;
  final int? correctedByLogId;

  bool get isVoided => voidedAt != null;
}

class MedicationReminder {
  const MedicationReminder({
    required this.id,
    required this.memberName,
    required this.medicineName,
    required this.remindAt,
    required this.dosageText,
    required this.status,
    this.sourceLogId,
  });

  final int id;
  final String memberName;
  final String medicineName;
  final DateTime remindAt;
  final String dosageText;
  final MedicationReminderStatus status;
  final int? sourceLogId;
}

class MedicationLogMutation {
  const MedicationLogMutation({
    required this.reminder,
    required this.canceledReminderIds,
  });

  final MedicationReminder? reminder;
  final List<int> canceledReminderIds;
}

enum MedicationReminderStatus {
  scheduled('scheduled'),
  completed('completed'),
  skipped('skipped'),
  canceled('canceled');

  const MedicationReminderStatus(this.value);
  final String value;

  static MedicationReminderStatus parse(String value) =>
      values.firstWhere((item) => item.value == value, orElse: () => scheduled);
}

enum MedicineExpiryStatus { unknown, ok, expiringSoon, expired }

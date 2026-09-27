import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:little_hero/core/database/local_database_config.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'local_database.g.dart';

final localDatabaseProvider = Provider<LocalDatabase>((ref) {
  final database = LocalDatabase();
  ref.onDispose(database.close);
  return database;
});

class LocalChildren extends Table {
  IntColumn get id => integer()();
  TextColumn get nickname => text().withDefault(const Constant('小勇士'))();
  TextColumn get gender => text().withDefault(const Constant('unknown'))();
  TextColumn get ageStage => text().withDefault(const Constant('5-6'))();
  TextColumn get avatarIcon =>
      text().withDefault(const Constant('face_rounded'))();
  TextColumn get avatarColor => text().withDefault(const Constant('green'))();
  BoolColumn get needsProfileSetup =>
      boolean().withDefault(const Constant(true))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LocalHabits extends Table {
  IntColumn get id => integer()();
  IntColumn get childId => integer()();
  TextColumn get name => text()();
  TextColumn get iconName => text().withDefault(const Constant('task_alt'))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LocalHabitRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get childId => integer()();
  IntColumn get habitId => integer()();
  TextColumn get recordDate => text()();
  TextColumn get status => text().withDefault(const Constant('none'))();
  TextColumn get operationId => text().withDefault(const Constant(''))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class LocalAssetSnapshots extends Table {
  IntColumn get childId => integer()();
  IntColumn get availableStars => integer().withDefault(const Constant(0))();
  IntColumn get lifetimeStars => integer().withDefault(const Constant(0))();
  IntColumn get badgeCount => integer().withDefault(const Constant(0))();
  IntColumn get heartsRemaining => integer().withDefault(const Constant(10))();
  IntColumn get heartsLimit => integer().withDefault(const Constant(10))();
  TextColumn get snapshotDate => text()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {childId};
}

class LocalChildBadges extends Table {
  TextColumn get code => text()();
  IntColumn get childId => integer()();
  TextColumn get name => text()();
  TextColumn get iconName =>
      text().withDefault(const Constant('workspace_premium_rounded'))();
  TextColumn get earnedDate => text()();

  @override
  Set<Column<Object>> get primaryKey => {childId, code};
}

class LocalDailyAwards extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get childId => integer()();
  TextColumn get awardDate => text()();
  TextColumn get awardType => text()();
  IntColumn get stars => integer()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class LocalRestDays extends Table {
  IntColumn get childId => integer()();
  TextColumn get restDate => text()();
  TextColumn get note => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {childId, restDate};
}

class LocalRewards extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get childId => integer()();
  TextColumn get title => text()();
  IntColumn get costStars => integer()();
  TextColumn get iconName =>
      text().withDefault(const Constant('redeem_rounded'))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class LocalRewardRedemptions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get childId => integer()();
  IntColumn get rewardId => integer().nullable()();
  TextColumn get rewardTitle => text()();
  IntColumn get costStars => integer()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  DateTimeColumn get requestedAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get resolvedAt => dateTime().nullable()();
  TextColumn get resolutionNote => text().withDefault(const Constant(''))();
}

class SyncOperations extends Table {
  TextColumn get operationId => text()();
  TextColumn get operationType => text()();
  TextColumn get entityId => text()();
  TextColumn get payloadJson => text()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  IntColumn get attemptCount => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {operationId};
}

class LocalCycleProfiles extends Table {
  IntColumn get id => integer()();
  TextColumn get lastPeriodStartDate => text().nullable()();
  IntColumn get periodLengthDays => integer().withDefault(const Constant(5))();
  IntColumn get cycleLengthDays => integer().withDefault(const Constant(28))();
  TextColumn get birthDate => text().nullable()();
  BoolColumn get isSetupComplete =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get cloudSyncEnabled =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LocalCycleDayLogs extends Table {
  TextColumn get logDate => text()();
  TextColumn get diaryText => text().withDefault(const Constant(''))();
  TextColumn get flowLevel => text().withDefault(const Constant('none'))();
  TextColumn get symptomsJson => text().withDefault(const Constant('[]'))();
  TextColumn get operationId => text().withDefault(const Constant(''))();
  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {logDate};
}

class LocalMedicationMembers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get relation => text().withDefault(const Constant('家庭成员'))();
  TextColumn get ageNote => text().withDefault(const Constant(''))();
  TextColumn get allergyNote => text().withDefault(const Constant(''))();
  TextColumn get conditionNote => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class LocalMedicines extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get specification => text().withDefault(const Constant(''))();
  TextColumn get defaultDosage => text().withDefault(const Constant(''))();
  TextColumn get storageLocation => text().withDefault(const Constant(''))();
  TextColumn get expiresOn => text().nullable()();
  TextColumn get stockNote => text().withDefault(const Constant(''))();
  TextColumn get usageNote => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class LocalMedicationLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get memberId => integer().nullable()();
  IntColumn get medicineId => integer().nullable()();
  TextColumn get memberName => text()();
  TextColumn get medicineName => text()();
  DateTimeColumn get takenAt => dateTime()();
  TextColumn get dosageText => text().withDefault(const Constant(''))();
  TextColumn get reason => text().withDefault(const Constant(''))();
  TextColumn get note => text().withDefault(const Constant(''))();
  DateTimeColumn get nextReminderAt => dateTime().nullable()();
  DateTimeColumn get voidedAt => dateTime().nullable()();
  TextColumn get voidReason => text().withDefault(const Constant(''))();
  IntColumn get correctedByLogId => integer().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class LocalMedicationReminders extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get memberId => integer().nullable()();
  IntColumn get medicineId => integer().nullable()();
  IntColumn get sourceLogId => integer().nullable()();
  TextColumn get memberName => text()();
  TextColumn get medicineName => text()();
  DateTimeColumn get remindAt => dateTime()();
  TextColumn get dosageText => text().withDefault(const Constant(''))();
  TextColumn get status => text().withDefault(const Constant('scheduled'))();
  DateTimeColumn get resolvedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(
  tables: [
    LocalChildren,
    LocalHabits,
    LocalHabitRecords,
    LocalAssetSnapshots,
    LocalChildBadges,
    LocalDailyAwards,
    LocalRestDays,
    LocalRewards,
    LocalRewardRedemptions,
    SyncOperations,
    LocalCycleProfiles,
    LocalCycleDayLogs,
    LocalMedicationMembers,
    LocalMedicines,
    LocalMedicationLogs,
    LocalMedicationReminders,
  ],
)
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase() : super(_openConnection());

  LocalDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => LocalDatabaseConfig.schemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    onUpgrade: (migrator, from, to) async {
      if (from < 3) {
        await migrator.createTable(localCycleProfiles);
        await migrator.createTable(localCycleDayLogs);
      }
      if (from < 4) {
        await migrator.createTable(localMedicationMembers);
        await migrator.createTable(localMedicines);
        await migrator.createTable(localMedicationLogs);
      }
      if (from < 5) {
        await migrator.createTable(localMedicationReminders);
        await customStatement('''
          INSERT INTO local_medication_reminders
            (member_id, medicine_id, source_log_id, member_name, medicine_name,
             remind_at, dosage_text, status, created_at, updated_at)
          SELECT member_id, medicine_id, id, member_name, medicine_name,
                 next_reminder_at, dosage_text, 'scheduled', created_at, created_at
          FROM local_medication_logs
          WHERE next_reminder_at IS NOT NULL
        ''');
      }
      if (from < 6) {
        await migrator.addColumn(
          localMedicationLogs,
          localMedicationLogs.voidedAt,
        );
        await migrator.addColumn(
          localMedicationLogs,
          localMedicationLogs.voidReason,
        );
        await migrator.addColumn(
          localMedicationLogs,
          localMedicationLogs.correctedByLogId,
        );
      }
      if (from < 7) {
        await migrator.createTable(localRestDays);
        await migrator.createTable(localRewards);
        await migrator.createTable(localRewardRedemptions);
      }
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(p.join(directory.path, LocalDatabaseConfig.fileName));
    return NativeDatabase.createInBackground(file);
  });
}

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
  TextColumn get avatarIcon => text().withDefault(const Constant('face_rounded'))();
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

@DriftDatabase(
  tables: [
    LocalChildren,
    LocalHabits,
    LocalHabitRecords,
    LocalAssetSnapshots,
    LocalChildBadges,
    LocalDailyAwards,
    SyncOperations,
  ],
)
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase() : super(_openConnection());

  @override
  int get schemaVersion => LocalDatabaseConfig.schemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    onUpgrade: (migrator, from, to) async {},
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(p.join(directory.path, LocalDatabaseConfig.fileName));
    return NativeDatabase.createInBackground(file);
  });
}

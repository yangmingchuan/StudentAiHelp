import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:little_hero/core/database/local_database.dart';
import 'package:little_hero/core/sync/operation_id_factory.dart';
import 'package:little_hero/features/today_tasks/data/home_api.dart';
import 'package:little_hero/features/today_tasks/domain/home_snapshot.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepository(
    ref.watch(localDatabaseProvider),
    ref.watch(homeApiProvider),
    ref.watch(operationIdFactoryProvider),
  );
});

class HomeRepository {
  const HomeRepository(this._db, this._api, this._operationIdFactory);

  final LocalDatabase _db;
  final HomeApi _api;
  final OperationIdFactory _operationIdFactory;

  Future<HomeSnapshot> load({bool refreshRemote = true}) async {
    await _ensureLocalDefaults();
    if (refreshRemote) {
      try {
        final remote = await _api.bootstrap();
        await _upsertBootstrap(remote);
        await _flushPendingOperations();
        return _readSnapshot(isStale: false);
      } catch (_) {
        return _readSnapshot(isStale: true, message: '正在使用本地缓存');
      }
    }
    return _readSnapshot(isStale: false);
  }

  Future<HomeSnapshot> setTaskStatus({
    required int taskId,
    required TaskStatus nextStatus,
  }) async {
    final operationId = _operationIdFactory.create();
    await _db.transaction(() async {
      final child = await _activeChild();
      final today = _today();
      final oldRecord = await _recordFor(child.id, taskId, today);
      final oldStatus = TaskStatus.parse(oldRecord?.status ?? 'none');
      final appliedStatus = oldStatus == nextStatus
          ? TaskStatus.none
          : nextStatus;

      await _upsertRecord(
        childId: child.id,
        taskId: taskId,
        recordDate: today,
        status: appliedStatus.name,
        operationId: operationId,
      );

      final delta = _taskStarDelta(oldStatus, appliedStatus);
      if (delta != 0) {
        await _changeStars(child.id, delta);
      }

      final newFull = await _isFullCompletionDay(child.id, today);
      await _applyDailyAward(
        childId: child.id,
        date: today,
        awardType: 'full_completion',
        stars: 2,
        shouldExist: newFull,
      );

      final hasSevenDayStreak = newFull &&
          await _hasFullCompletionStreak(child.id, today, days: 7);
      await _applyDailyAward(
        childId: child.id,
        date: today,
        awardType: 'seven_day_streak',
        stars: 5,
        shouldExist: hasSevenDayStreak,
      );

      await _enqueueOperation(
        operationId: operationId,
        operationType: 'task_status',
        entityId: taskId.toString(),
        payload: {
          'childId': child.id,
          'taskId': taskId,
          'status': appliedStatus.name,
        },
      );
    });

    unawaitedFlush();
    return _readSnapshot(isStale: false, isSyncing: true);
  }

  Future<HomeSnapshot> addTask({required String name}) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('任务名称不能为空');
    }
    if (_visualLength(trimmed) > 7) {
      throw ArgumentError('任务名称最多 7 个汉字');
    }

    await _db.transaction(() async {
      final child = await _activeChild();
      final tasks = await _activeTasks(child.id);
      if (tasks.length >= 10) {
        throw StateError('最多只能保留 10 个任务');
      }
      final id = DateTime.now().microsecondsSinceEpoch;
      await _db.into(_db.localHabits).insert(
            LocalHabitsCompanion.insert(
              id: Value(id),
              childId: child.id,
              name: trimmed,
              iconName: const Value('task_alt_rounded'),
              sortOrder: Value(
                tasks.isEmpty ? 10 : tasks.last.sortOrder + 10,
              ),
              isDirty: const Value(true),
            ),
          );
      await _enqueueOperation(
        operationId: _operationIdFactory.create(),
        operationType: 'task_create',
        entityId: id.toString(),
        payload: {'childId': child.id, 'taskId': id, 'name': trimmed},
      );
    });
    unawaitedFlush();
    return _readSnapshot(isStale: false, isSyncing: true);
  }

  Future<HomeSnapshot> updateTask({
    required int taskId,
    required String name,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('任务名称不能为空');
    }
    if (_visualLength(trimmed) > 7) {
      throw ArgumentError('任务名称最多 7 个汉字');
    }

    await (_db.update(_db.localHabits)..where((table) => table.id.equals(taskId)))
        .write(
      LocalHabitsCompanion(
        name: Value(trimmed),
        isDirty: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
    await _enqueueOperation(
      operationId: _operationIdFactory.create(),
      operationType: 'task_update',
      entityId: taskId.toString(),
      payload: {'taskId': taskId, 'name': trimmed},
    );
    unawaitedFlush();
    return _readSnapshot(isStale: false, isSyncing: true);
  }

  Future<HomeSnapshot> deleteTask(int taskId) async {
    final child = await _activeChild();
    final tasks = await _activeTasks(child.id);
    if (tasks.length <= 1) {
      throw StateError('至少保留 1 个任务');
    }

    await (_db.update(_db.localHabits)..where((table) => table.id.equals(taskId)))
        .write(
      LocalHabitsCompanion(
        isActive: const Value(false),
        isDirty: const Value(true),
        deletedAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );
    await _enqueueOperation(
      operationId: _operationIdFactory.create(),
      operationType: 'task_delete',
      entityId: taskId.toString(),
      payload: {'taskId': taskId},
    );
    unawaitedFlush();
    return _readSnapshot(isStale: false, isSyncing: true);
  }

  Future<HomeSnapshot> moveTask(int oldIndex, int newIndex) async {
    final child = await _activeChild();
    final tasks = await _activeTasks(child.id);
    if (oldIndex < 0 || oldIndex >= tasks.length) {
      return _readSnapshot(isStale: false);
    }
    final moved = tasks.removeAt(oldIndex);
    tasks.insert(newIndex.clamp(0, tasks.length).toInt(), moved);

    await _db.transaction(() async {
      for (var index = 0; index < tasks.length; index += 1) {
        await (_db.update(_db.localHabits)
              ..where((table) => table.id.equals(tasks[index].id)))
            .write(
          LocalHabitsCompanion(
            sortOrder: Value((index + 1) * 10),
            isDirty: const Value(true),
          ),
        );
      }
      await _enqueueOperation(
        operationId: _operationIdFactory.create(),
        operationType: 'task_reorder',
        entityId: child.id.toString(),
        payload: {
          'childId': child.id,
          'taskIds': tasks.map((task) => task.id).toList(),
        },
      );
    });
    unawaitedFlush();
    return _readSnapshot(isStale: false, isSyncing: true);
  }

  Future<void> _flushPendingOperations() async {
    final operations = await (_db.select(_db.syncOperations)
          ..where((table) => table.status.equals('pending'))
          ..orderBy([(table) => OrderingTerm.asc(table.createdAt)]))
        .get();

    for (final operation in operations) {
      try {
        final payload = jsonDecode(operation.payloadJson);
        if (payload is Map<String, dynamic> &&
            operation.operationType == 'task_status') {
          await _api.submitTaskStatus(
            operationId: operation.operationId,
            childId: payload['childId'] as int,
            taskId: payload['taskId'] as int,
            status: payload['status'] as String,
          );
        } else if (payload is Map<String, dynamic> &&
            operation.operationType.startsWith('task_')) {
          await _api.submitTaskManagement(
            operationId: operation.operationId,
            action: operation.operationType.replaceFirst('task_', ''),
            payload: payload,
          );
        }
        await (_db.update(_db.syncOperations)
              ..where((table) => table.operationId.equals(operation.operationId)))
            .write(
          SyncOperationsCompanion(
            status: const Value('synced'),
            updatedAt: Value(DateTime.now()),
          ),
        );
      } catch (error) {
        await (_db.update(_db.syncOperations)
              ..where((table) => table.operationId.equals(operation.operationId)))
            .write(
          SyncOperationsCompanion(
            attemptCount: Value(operation.attemptCount + 1),
            lastError: Value(error.toString()),
            updatedAt: Value(DateTime.now()),
          ),
        );
        break;
      }
    }
  }

  void unawaitedFlush() {
    _flushPendingOperations();
  }

  Future<void> _ensureLocalDefaults() async {
    final children = await _db.select(_db.localChildren).get();
    if (children.isNotEmpty) {
      return;
    }

    await _db.transaction(() async {
      await _db.into(_db.localChildren).insert(
            LocalChildrenCompanion.insert(
              id: const Value(1),
              nickname: const Value('小勇士'),
            ),
          );
      await _db.into(_db.localAssetSnapshots).insert(
            LocalAssetSnapshotsCompanion.insert(
              childId: const Value(1),
              snapshotDate: _today(),
            ),
          );
      await _insertDefaultTask(1, 101, '自己刷牙', 'clean_hands_rounded', 10);
      await _insertDefaultTask(1, 102, '整理床铺', 'bed_rounded', 20);
      await _insertDefaultTask(1, 103, '阅读绘本', 'auto_stories_rounded', 30);
    });
  }

  Future<void> _insertDefaultTask(
    int childId,
    int id,
    String name,
    String iconName,
    int sortOrder,
  ) {
    return _db.into(_db.localHabits).insertOnConflictUpdate(
          LocalHabitsCompanion.insert(
            id: Value(id),
            childId: childId,
            name: name,
            iconName: Value(iconName),
            sortOrder: Value(sortOrder),
          ),
        );
  }

  Future<void> _upsertBootstrap(Map<String, dynamic> data) async {
    final child = data['child'] as Map<String, dynamic>? ?? {};
    final assets = data['assets'] as Map<String, dynamic>? ?? {};
    final hearts = assets['hearts'] as Map<String, dynamic>? ?? {};
    final badges = data['badges'] as Map<String, dynamic>? ?? {};
    final tasks = data['todayTasks'] as List<dynamic>? ?? const [];
    final childId = _asInt(child['id'], fallback: 1);

    await _db.transaction(() async {
      await _db.into(_db.localChildren).insertOnConflictUpdate(
            LocalChildrenCompanion.insert(
              id: Value(childId),
              nickname: Value(child['nickname']?.toString() ?? '小勇士'),
              gender: Value(child['gender']?.toString() ?? 'unknown'),
              ageStage: Value(child['ageStage']?.toString() ?? '5-6'),
              avatarIcon: Value(
                (child['avatarConfig'] is Map
                        ? child['avatarConfig']['icon']
                        : null)
                    ?.toString() ??
                    'face_rounded',
              ),
              avatarColor: Value(
                (child['avatarConfig'] is Map
                        ? child['avatarConfig']['color']
                        : null)
                    ?.toString() ??
                    'green',
              ),
              needsProfileSetup: Value(child['needsProfileSetup'] == true),
            ),
          );
      await _db.into(_db.localAssetSnapshots).insertOnConflictUpdate(
            LocalAssetSnapshotsCompanion.insert(
              childId: Value(childId),
              availableStars: Value(_asInt(assets['availableStars'])),
              lifetimeStars: Value(_asInt(assets['lifetimeStars'])),
              badgeCount: Value(_asInt(badges['earnedCount'])),
              heartsRemaining: Value(_asInt(hearts['remaining'], fallback: 10)),
              heartsLimit: Value(_asInt(hearts['limit'], fallback: 10)),
              snapshotDate: data['serverDate']?.toString() ?? _today(),
            ),
          );

      for (final item in tasks) {
        if (item is! Map<String, dynamic>) continue;
        final id = _asInt(item['id']);
        if (id == 0) continue;
        await _db.into(_db.localHabits).insertOnConflictUpdate(
              LocalHabitsCompanion.insert(
                id: Value(id),
                childId: childId,
                name: item['name']?.toString() ?? '任务',
                iconName: Value(item['iconName']?.toString() ?? 'task_alt'),
                sortOrder: Value(_asInt(item['sortOrder'])),
              ),
            );
        await _upsertRecord(
          childId: childId,
          taskId: id,
          recordDate: data['serverDate']?.toString() ?? _today(),
          status: item['status']?.toString() ?? 'none',
          operationId: '',
        );
      }
    });
  }

  Future<HomeSnapshot> _readSnapshot({
    required bool isStale,
    bool isSyncing = false,
    String? message,
  }) async {
    final child = await _activeChild();
    final tasks = await _activeTasks(child.id);
    final today = _today();
    final records = await (_db.select(_db.localHabitRecords)
          ..where(
            (table) =>
                table.childId.equals(child.id) & table.recordDate.equals(today),
          ))
        .get();
    final recordByTask = {for (final record in records) record.habitId: record};
    final asset = await (_db.select(_db.localAssetSnapshots)
          ..where((table) => table.childId.equals(child.id)))
        .getSingleOrNull();
    final badges = await (_db.select(_db.localChildBadges)
          ..where((table) => table.childId.equals(child.id)))
        .get();

    return HomeSnapshot(
      child: ChildSummary(
        id: child.id,
        nickname: child.nickname,
        avatarIcon: child.avatarIcon,
        avatarColor: child.avatarColor,
        needsProfileSetup: child.needsProfileSetup,
      ),
      assets: AssetSummary(
        availableStars: asset?.availableStars ?? 0,
        lifetimeStars: asset?.lifetimeStars ?? 0,
        badgeCount: badges.length,
        heartsRemaining: asset?.heartsRemaining ?? 10,
        heartsLimit: asset?.heartsLimit ?? 10,
      ),
      tasks: [
        for (final task in tasks)
          TaskSummary(
            id: task.id,
            name: task.name,
            iconName: task.iconName,
            sortOrder: task.sortOrder,
            status: TaskStatus.parse(recordByTask[task.id]?.status ?? 'none'),
          ),
      ],
      badges: BadgeSummary(earnedCount: badges.length, totalCount: 3),
      isStale: isStale,
      isSyncing: isSyncing,
      message: message,
    );
  }

  Future<LocalChildrenData> _activeChild() async {
    return (_db.select(_db.localChildren)..limit(1)).getSingle();
  }

  Future<List<LocalHabit>> _activeTasks(int childId) {
    return (_db.select(_db.localHabits)
          ..where(
            (table) =>
                table.childId.equals(childId) &
                table.isActive.equals(true) &
                table.deletedAt.isNull(),
          )
          ..orderBy([(table) => OrderingTerm.asc(table.sortOrder)]))
        .get();
  }

  Future<LocalHabitRecord?> _recordFor(
    int childId,
    int taskId,
    String date,
  ) {
    return (_db.select(_db.localHabitRecords)
          ..where(
            (table) =>
                table.childId.equals(childId) &
                table.habitId.equals(taskId) &
                table.recordDate.equals(date),
          ))
        .getSingleOrNull();
  }

  Future<void> _upsertRecord({
    required int childId,
    required int taskId,
    required String recordDate,
    required String status,
    required String operationId,
  }) async {
    final existing = await _recordFor(childId, taskId, recordDate);
    if (existing == null) {
      await _db.into(_db.localHabitRecords).insert(
            LocalHabitRecordsCompanion.insert(
              childId: childId,
              habitId: taskId,
              recordDate: recordDate,
              status: Value(status),
              operationId: Value(operationId),
            ),
          );
    } else {
      await (_db.update(_db.localHabitRecords)
            ..where((table) => table.id.equals(existing.id)))
          .write(
        LocalHabitRecordsCompanion(
          status: Value(status),
          operationId: Value(operationId),
          updatedAt: Value(DateTime.now()),
        ),
      );
    }
  }

  Future<bool> _isFullCompletionDay(int childId, String date) async {
    final tasks = await _activeTasks(childId);
    if (tasks.isEmpty) {
      return false;
    }
    final records = await (_db.select(_db.localHabitRecords)
          ..where(
            (table) =>
                table.childId.equals(childId) &
                table.recordDate.equals(date) &
                table.status.equals('done'),
          ))
        .get();
    final doneIds = records.map((record) => record.habitId).toSet();
    return tasks.every((task) => doneIds.contains(task.id));
  }

  Future<bool> _hasFullCompletionStreak(
    int childId,
    String today, {
    required int days,
  }) async {
    final date = DateTime.parse(today);
    for (var offset = 0; offset < days; offset += 1) {
      final day = _formatDate(date.subtract(Duration(days: offset)));
      if (!await _isFullCompletionDay(childId, day)) {
        return false;
      }
    }
    return true;
  }

  Future<void> _applyDailyAward({
    required int childId,
    required String date,
    required String awardType,
    required int stars,
    required bool shouldExist,
  }) async {
    final existing = await (_db.select(_db.localDailyAwards)
          ..where(
            (table) =>
                table.childId.equals(childId) &
                table.awardDate.equals(date) &
                table.awardType.equals(awardType),
          ))
        .getSingleOrNull();
    if (shouldExist && existing == null) {
      await _db.into(_db.localDailyAwards).insert(
            LocalDailyAwardsCompanion.insert(
              childId: childId,
              awardDate: date,
              awardType: awardType,
              stars: stars,
            ),
          );
      await _changeStars(childId, stars);
    } else if (!shouldExist && existing != null) {
      await (_db.delete(_db.localDailyAwards)
            ..where((table) => table.id.equals(existing.id)))
          .go();
      await _changeStars(childId, -stars);
    }
  }

  int _taskStarDelta(TaskStatus oldStatus, TaskStatus newStatus) {
    final oldStars = oldStatus == TaskStatus.done ? 1 : 0;
    final newStars = newStatus == TaskStatus.done ? 1 : 0;
    return newStars - oldStars;
  }

  Future<void> _changeStars(int childId, int delta) async {
    final asset = await (_db.select(_db.localAssetSnapshots)
          ..where((table) => table.childId.equals(childId)))
        .getSingleOrNull();
    final available = ((asset?.availableStars ?? 0) + delta)
        .clamp(0, 1 << 30)
        .toInt();
    final lifetime = ((asset?.lifetimeStars ?? 0) + delta)
        .clamp(0, 1 << 30)
        .toInt();
    await _db.into(_db.localAssetSnapshots).insertOnConflictUpdate(
          LocalAssetSnapshotsCompanion.insert(
            childId: Value(childId),
            availableStars: Value(available),
            lifetimeStars: Value(lifetime),
            badgeCount: Value(asset?.badgeCount ?? 0),
            heartsRemaining: Value(asset?.heartsRemaining ?? 10),
            heartsLimit: Value(asset?.heartsLimit ?? 10),
            snapshotDate: asset?.snapshotDate ?? _today(),
          ),
        );
  }

  Future<void> _enqueueOperation({
    required String operationId,
    required String operationType,
    required String entityId,
    required Map<String, Object?> payload,
  }) {
    return _db.into(_db.syncOperations).insertOnConflictUpdate(
          SyncOperationsCompanion.insert(
            operationId: operationId,
            operationType: operationType,
            entityId: entityId,
            payloadJson: jsonEncode(payload),
          ),
        );
  }

  String _today() => _formatDate(DateTime.now());

  String _formatDate(DateTime value) {
    final local = value.toLocal();
    return '${local.year.toString().padLeft(4, '0')}-'
        '${local.month.toString().padLeft(2, '0')}-'
        '${local.day.toString().padLeft(2, '0')}';
  }

  int _asInt(Object? value, {int fallback = 0}) {
    return switch (value) {
      final int number => number,
      final num number => number.toInt(),
      final String string => int.tryParse(string) ?? fallback,
      _ => fallback,
    };
  }

  double _visualLength(String value) {
    return value.runes.fold<double>(
      0,
      (sum, rune) => sum + (rune > 255 ? 1 : 0.5),
    );
  }
}

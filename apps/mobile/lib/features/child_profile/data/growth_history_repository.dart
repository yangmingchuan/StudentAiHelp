import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:little_hero/core/database/local_database.dart';
import 'package:little_hero/features/child_profile/domain/growth_history.dart';
import 'package:little_hero/features/today_tasks/application/home_controller.dart';
import 'package:little_hero/features/today_tasks/domain/home_snapshot.dart';

final growthHistoryRepositoryProvider = Provider<GrowthHistoryRepository>((
  ref,
) {
  return GrowthHistoryRepository(ref.watch(localDatabaseProvider));
});

final growthHistoryProvider = FutureProvider<GrowthHistorySnapshot>((
  ref,
) async {
  // A newly checked task refreshes the current screen's history immediately.
  ref.watch(homeControllerProvider);
  return ref.watch(growthHistoryRepositoryProvider).load();
});

class GrowthHistoryRepository {
  const GrowthHistoryRepository(this._db);

  final LocalDatabase _db;

  Future<GrowthHistorySnapshot> load({int days = 28}) async {
    final end = _dateOnly(DateTime.now());
    final start = end.subtract(Duration(days: days - 1));
    final child = await (_db.select(
      _db.localChildren,
    )..limit(1)).getSingleOrNull();
    if (child == null) {
      return GrowthHistorySnapshot(
        childId: 0,
        days: [
          for (var offset = 0; offset < days; offset += 1)
            GrowthHistoryDay(
              date: start.add(Duration(days: offset)),
              totalCount: 0,
              doneCount: 0,
              skippedCount: 0,
              tasks: const [],
            ),
        ],
        totalTasks: 0,
        currentStreak: 0,
        bestStreak: 0,
      );
    }
    final habits =
        await (_db.select(_db.localHabits)
              ..where((table) => table.childId.equals(child.id))
              ..orderBy([(table) => OrderingTerm.asc(table.sortOrder)]))
            .get();
    final records =
        await (_db.select(_db.localHabitRecords)..where(
              (table) =>
                  table.childId.equals(child.id) &
                  table.recordDate.isBiggerOrEqualValue(growthDateKey(start)) &
                  table.recordDate.isSmallerOrEqualValue(growthDateKey(end)),
            ))
            .get();
    final recordsByDate = <String, Map<int, LocalHabitRecord>>{};
    for (final record in records) {
      (recordsByDate[record.recordDate] ??= {})[record.habitId] = record;
    }
    final visibleHabits = habits
        .where((habit) => habit.deletedAt == null)
        .toList();
    final daysList = <GrowthHistoryDay>[];
    for (var offset = 0; offset < days; offset += 1) {
      final date = start.add(Duration(days: offset));
      final recordsForDay = recordsByDate[growthDateKey(date)] ?? const {};
      // A task removed today must remain visible in the dates where it was
      // completed. Otherwise the history would silently rewrite a past win.
      final habitsForDay = [
        ...visibleHabits,
        ...habits.where(
          (habit) =>
              habit.deletedAt != null && recordsForDay.containsKey(habit.id),
        ),
      ];
      final tasks = [
        for (final habit in habitsForDay)
          GrowthHistoryTask(
            id: habit.id,
            name: habit.name,
            iconName: habit.iconName,
            status: TaskStatus.parse(recordsForDay[habit.id]?.status ?? 'none'),
          ),
      ];
      daysList.add(
        GrowthHistoryDay(
          date: date,
          totalCount: tasks.length,
          doneCount: tasks
              .where((task) => task.status == TaskStatus.done)
              .length,
          skippedCount: tasks
              .where((task) => task.status == TaskStatus.skipped)
              .length,
          tasks: tasks,
        ),
      );
    }
    final streaks = _streaks(daysList);
    return GrowthHistorySnapshot(
      childId: child.id,
      days: daysList,
      totalTasks: visibleHabits.length,
      currentStreak: streaks.$1,
      bestStreak: streaks.$2,
    );
  }

  (int, int) _streaks(List<GrowthHistoryDay> days) {
    var current = 0;
    for (final day in days.reversed) {
      if (!day.isFull) break;
      current += 1;
    }
    var best = 0;
    var running = 0;
    for (final day in days) {
      if (day.isFull) {
        running += 1;
        if (running > best) best = running;
      } else {
        running = 0;
      }
    }
    return (current, best);
  }

  DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}

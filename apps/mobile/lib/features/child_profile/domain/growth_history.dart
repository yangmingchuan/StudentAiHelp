import 'package:little_hero/features/today_tasks/domain/home_snapshot.dart';

class GrowthHistorySnapshot {
  const GrowthHistorySnapshot({
    required this.childId,
    required this.days,
    required this.totalTasks,
    required this.currentStreak,
    required this.bestStreak,
  });

  final int childId;
  final List<GrowthHistoryDay> days;
  final int totalTasks;
  final int currentStreak;
  final int bestStreak;

  GrowthHistoryDay? dayFor(DateTime date) {
    final key = growthDateKey(date);
    for (final day in days) {
      if (growthDateKey(day.date) == key) return day;
    }
    return null;
  }
}

class GrowthHistoryDay {
  const GrowthHistoryDay({
    required this.date,
    required this.totalCount,
    required this.doneCount,
    required this.skippedCount,
    required this.tasks,
  });

  final DateTime date;
  final int totalCount;
  final int doneCount;
  final int skippedCount;
  final List<GrowthHistoryTask> tasks;

  bool get hasActivity => tasks.any((task) => task.status != TaskStatus.none);
  double get progress => totalCount == 0 ? 0 : doneCount / totalCount;
  bool get isFull => totalCount > 0 && doneCount == totalCount;
}

class GrowthHistoryTask {
  const GrowthHistoryTask({
    required this.id,
    required this.name,
    required this.iconName,
    required this.status,
  });

  final int id;
  final String name;
  final String iconName;
  final TaskStatus status;
}

String growthDateKey(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

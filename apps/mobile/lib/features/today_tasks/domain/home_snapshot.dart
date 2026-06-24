class HomeSnapshot {
  const HomeSnapshot({
    required this.child,
    required this.assets,
    required this.tasks,
    required this.badges,
    required this.isStale,
    required this.isSyncing,
    this.message,
  });

  final ChildSummary child;
  final AssetSummary assets;
  final List<TaskSummary> tasks;
  final BadgeSummary badges;
  final bool isStale;
  final bool isSyncing;
  final String? message;
}

class ChildSummary {
  const ChildSummary({
    required this.id,
    required this.nickname,
    required this.avatarIcon,
    required this.avatarColor,
    required this.needsProfileSetup,
  });

  final int id;
  final String nickname;
  final String avatarIcon;
  final String avatarColor;
  final bool needsProfileSetup;
}

class AssetSummary {
  const AssetSummary({
    required this.availableStars,
    required this.lifetimeStars,
    required this.badgeCount,
    required this.heartsRemaining,
    required this.heartsLimit,
  });

  final int availableStars;
  final int lifetimeStars;
  final int badgeCount;
  final int heartsRemaining;
  final int heartsLimit;
}

class TaskSummary {
  const TaskSummary({
    required this.id,
    required this.name,
    required this.iconName,
    required this.sortOrder,
    required this.status,
  });

  final int id;
  final String name;
  final String iconName;
  final int sortOrder;
  final TaskStatus status;

  bool get isDone => status == TaskStatus.done;
  bool get isSkipped => status == TaskStatus.skipped;
}

enum TaskStatus {
  none,
  done,
  skipped;

  static TaskStatus parse(String value) {
    return switch (value) {
      'done' => TaskStatus.done,
      'skipped' => TaskStatus.skipped,
      _ => TaskStatus.none,
    };
  }
}

class BadgeSummary {
  const BadgeSummary({required this.earnedCount, required this.totalCount});

  final int earnedCount;
  final int totalCount;
}

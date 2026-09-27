import 'package:little_hero/core/widgets/tab_header.dart';
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:little_hero/features/today_tasks/application/home_controller.dart';
import 'package:little_hero/features/today_tasks/domain/home_snapshot.dart';

class TodayTasksPage extends ConsumerStatefulWidget {
  const TodayTasksPage({super.key});

  @override
  ConsumerState<TodayTasksPage> createState() => _TodayTasksPageState();
}

class _TodayTasksPageState extends ConsumerState<TodayTasksPage>
    with SingleTickerProviderStateMixin {
  final _pageKey = GlobalKey();
  final _starTargetKey = GlobalKey();
  late final AnimationController _starController;
  Offset? _starStart;
  Offset? _starEnd;
  int _flightId = 0;
  Timer? _themeTimer;

  @override
  void initState() {
    super.initState();
    _starController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scheduleThemeRefresh();
  }

  void _scheduleThemeRefresh() {
    _themeTimer?.cancel();
    final now = DateTime.now();
    final boundary = now.hour < 7
        ? DateTime(now.year, now.month, now.day, 7)
        : now.hour < 17
        ? DateTime(now.year, now.month, now.day, 17)
        : DateTime(now.year, now.month, now.day + 1, 7);
    _themeTimer = Timer(
      boundary.difference(now) + const Duration(seconds: 1),
      () {
        if (mounted) setState(() {});
        _scheduleThemeRefresh();
      },
    );
  }

  @override
  void dispose() {
    _themeTimer?.cancel();
    _starController.dispose();
    super.dispose();
  }

  Future<void> _toggleTask(TaskSummary task, BuildContext source) async {
    if (task.isDone) {
      await ref.read(homeControllerProvider.notifier).clearTaskStatus(task.id);
      return;
    }
    final start = _centerInPage(source);
    final end = _centerForKey(_starTargetKey);
    await ref
        .read(homeControllerProvider.notifier)
        .setTaskStatus(task.id, TaskStatus.done);
    if (!mounted) return;
    final completed =
        ref
            .read(homeControllerProvider)
            .asData
            ?.value
            .tasks
            .any((item) => item.id == task.id && item.isDone) ??
        false;
    if (!completed) return;
    setState(() {
      _starStart = start ?? Offset(MediaQuery.sizeOf(context).width - 52, 300);
      _starEnd = end ?? Offset(MediaQuery.sizeOf(context).width * .22, 230);
      _flightId += 1;
    });
    _starController.forward(from: 0);
  }

  Offset? _centerForKey(GlobalKey key) {
    final target = key.currentContext;
    return target == null ? null : _centerInPage(target);
  }

  Offset? _centerInPage(BuildContext childContext) {
    final child = childContext.findRenderObject();
    final page = _pageKey.currentContext?.findRenderObject();
    if (child is! RenderBox || page is! RenderBox) return null;
    if (!child.attached || !page.attached) return null;
    return page.globalToLocal(
      child.localToGlobal(child.size.center(Offset.zero)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeControllerProvider);
    return state.when(
      loading: () =>
          const SafeArea(child: Center(child: CircularProgressIndicator())),
      error: (error, _) => SafeArea(
        child: _ErrorView(
          message: error.toString(),
          onRetry: () => ref.read(homeControllerProvider.notifier).refresh(),
        ),
      ),
      data: (snapshot) {
        final theme = _CatTheme.forNow();
        final completed = snapshot.tasks.where((task) => task.isDone).length;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: theme.isDay
              ? SystemUiOverlayStyle.dark
              : SystemUiOverlayStyle.light,
          child: Stack(
            key: _pageKey,
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: Image.asset(theme.backgroundAsset, fit: BoxFit.cover),
              ),
              SafeArea(
                bottom: false,
                child: RefreshIndicator(
                  color: theme.accent,
                  onRefresh: () =>
                      ref.read(homeControllerProvider.notifier).refresh(),
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
                        sliver: SliverToBoxAdapter(
                          child: _Hero(
                            theme: theme,
                            taskCount: snapshot.tasks.length,
                            completedCount: completed,
                            starTargetKey: _starTargetKey,
                          ),
                        ),
                      ),
                      if (snapshot.isSyncing || snapshot.message != null)
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                          sliver: SliverToBoxAdapter(
                            child: _SyncNotice(
                              text: snapshot.isSyncing
                                  ? '正在同步今天的变化'
                                  : snapshot.message!,
                              theme: theme,
                            ),
                          ),
                        ),
                      if (snapshot.isRestDay)
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                          sliver: SliverToBoxAdapter(
                            child: _RestDayNotice(theme: theme),
                          ),
                        ),
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          20,
                          4,
                          20,
                          MediaQuery.paddingOf(context).bottom + 28,
                        ),
                        sliver: SliverList.separated(
                          itemCount: snapshot.tasks.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 14),
                          itemBuilder: (context, index) => _TaskTile(
                            task: snapshot.tasks[index],
                            theme: theme,
                            onToggle: snapshot.isRestDay
                                ? null
                                : (source) => _toggleTask(
                                    snapshot.tasks[index],
                                    source,
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_starStart != null && _starEnd != null)
                _StarFlight(
                  key: ValueKey(_flightId),
                  animation: _starController,
                  start: _starStart!,
                  end: _starEnd!,
                  color: theme.star,
                ),
            ],
          ),
        );
      },
    );
  }
}

class _CatTheme {
  const _CatTheme({
    required this.isDay,
    required this.backgroundAsset,
    required this.text,
    required this.subtleText,
    required this.surface,
    required this.calendar,
    required this.progress,
    required this.accent,
    required this.complete,
    required this.star,
    required this.mascotAsset,
  });

  factory _CatTheme.forNow([DateTime? now]) {
    final hour = (now ?? DateTime.now()).hour;
    if (hour >= 7 && hour < 17) {
      return const _CatTheme(
        isDay: true,
        backgroundAsset: 'assets/backgrounds/day_meadow.png',
        text: Color(0xFF3F3026),
        subtleText: Color(0xFF735F50),
        surface: Color(0xFFFFFCF3),
        calendar: Color(0xCCFFFFFF),
        progress: Color(0xDFFFEFCA),
        accent: Color(0xFF187C4A),
        complete: Color(0xFF35B76C),
        star: Color(0xFFFFB62D),
        mascotAsset: 'assets/mascots/day_explorer_cat.png',
      );
    }
    return const _CatTheme(
      isDay: false,
      backgroundAsset: 'assets/backgrounds/night_moon.png',
      text: Color(0xFFF6F9FF),
      subtleText: Color(0xFFC9D7FF),
      surface: Color(0xDD12366E),
      calendar: Color(0xB3164C98),
      progress: Color(0xC30D3470),
      accent: Color(0xFF72D8FF),
      complete: Color(0xFF38D38A),
      star: Color(0xFFFFC132),
      mascotAsset: 'assets/mascots/night_astronaut_cat.png',
    );
  }

  final bool isDay;
  final String backgroundAsset;
  final Color text;
  final Color subtleText;
  final Color surface;
  final Color calendar;
  final Color progress;
  final Color accent;
  final Color complete;
  final Color star;
  final String mascotAsset;
}

class _Hero extends StatelessWidget {
  const _Hero({
    required this.theme,
    required this.taskCount,
    required this.completedCount,
    required this.starTargetKey,
  });

  final _CatTheme theme;
  final int taskCount;
  final int completedCount;
  final GlobalKey starTargetKey;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekday = const ['一', '二', '三', '四', '五', '六', '日'][now.weekday - 1];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TabHeader(
          showSurface: false,
          isDay: theme.isDay,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: _CalendarPill(
              theme: theme,
              label: '${now.month}月${now.day}日 · 星期$weekday',
            ),
          ),
        ),
        const SizedBox(height: 6),
        _ProgressStrip(
          key: starTargetKey,
          theme: theme,
          completedCount: completedCount,
          taskCount: taskCount,
        ),
      ],
    );
  }
}

class _CalendarPill extends StatelessWidget {
  const _CalendarPill({required this.theme, required this.label});
  final _CatTheme theme;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.calendar,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: theme.accent.withValues(alpha: .38)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_month_rounded, color: theme.accent, size: 17),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: theme.text,
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressStrip extends StatelessWidget {
  const _ProgressStrip({
    super.key,
    required this.theme,
    required this.completedCount,
    required this.taskCount,
  });

  final _CatTheme theme;
  final int completedCount;
  final int taskCount;

  @override
  Widget build(BuildContext context) {
    final count = taskCount.clamp(0, 10);
    final completed = completedCount.clamp(0, count);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.progress,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.accent.withValues(alpha: .26)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 7, 10, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '今日星星  $completed / $count',
              style: TextStyle(
                color: theme.text,
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 4),
            Semantics(
              label: '今日已完成 $completed 项，共 $count 项任务',
              child: Wrap(
                spacing: 3,
                runSpacing: 4,
                children: [
                  for (var index = 0; index < count; index++)
                    Icon(
                      index < completed
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: index < completed
                          ? theme.star
                          : theme.subtleText.withValues(alpha: .58),
                      size: 20,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({
    required this.task,
    required this.theme,
    required this.onToggle,
  });

  final TaskSummary task;
  final _CatTheme theme;
  final ValueChanged<BuildContext>? onToggle;

  @override
  Widget build(BuildContext context) {
    final visual = _TaskVisual.forTask(task);
    return Material(
      color: theme.surface,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onToggle == null ? null : () => onToggle!(context),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(13, 12, 12, 12),
          child: Row(
            children: [
              SizedBox(
                width: 70,
                height: 70,
                child: Image.asset(visual.asset, fit: BoxFit.contain),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: theme.text,
                        fontSize: 19,
                        height: 1.15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      visual.hint,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: theme.subtleText,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Builder(
                builder: (buttonContext) => Semantics(
                  button: true,
                  label: (task.isDone ? '取消完成 ' : '完成 ') + task.name,
                  child: IconButton(
                    tooltip: task.isDone ? '取消完成' : '完成',
                    onPressed: onToggle == null
                        ? null
                        : () => onToggle!(buttonContext),
                    style: IconButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(48, 48),
                    ),
                    icon: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: task.isDone
                            ? theme.complete
                            : Colors.transparent,
                        border: task.isDone
                            ? null
                            : Border.all(
                                color: theme.subtleText.withValues(alpha: .6),
                                width: 2,
                              ),
                      ),
                      child: task.isDone
                          ? const Icon(
                              Icons.check_rounded,
                              size: 21,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TaskVisual {
  const _TaskVisual({required this.asset, required this.hint});

  factory _TaskVisual.forTask(TaskSummary task) {
    final key = '${task.name} ${task.iconName}'.toLowerCase();
    if (key.contains('刷牙') || key.contains('clean')) {
      return const _TaskVisual(
        asset: 'assets/task_icons/brush.png',
        hint: '早晚刷牙，保护牙齿',
      );
    }
    if (key.contains('英语') || key.contains('阅读') || key.contains('stories')) {
      return const _TaskVisual(
        asset: 'assets/task_icons/reading.png',
        hint: '打开一本好书，探索新世界',
      );
    }
    if (key.contains('数学') || key.contains('math')) {
      return const _TaskVisual(
        asset: 'assets/task_icons/math.png',
        hint: '多动脑筋，变得更聪明',
      );
    }
    if (key.contains('玩具') || key.contains('整理')) {
      return const _TaskVisual(
        asset: 'assets/task_icons/toys.png',
        hint: '把玩具放回家，整洁又开心',
      );
    }
    if (key.contains('情绪') || key.contains('心情')) {
      return const _TaskVisual(
        asset: 'assets/task_icons/emotion.png',
        hint: '照顾好心情，开心每一天',
      );
    }
    if (key.contains('喝水') || key.contains('water')) {
      return const _TaskVisual(
        asset: 'assets/task_icons/water.png',
        hint: '补充水分，身体更有活力',
      );
    }
    return const _TaskVisual(
      asset: 'assets/task_icons/custom.png',
      hint: '完成一个小目标，收获成长星星',
    );
  }

  final String asset;
  final String hint;
}

class _RestDayNotice extends StatelessWidget {
  const _RestDayNotice({required this.theme});
  final _CatTheme theme;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: theme.calendar,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: theme.accent.withValues(alpha: 0.34)),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: Row(
        children: [
          Icon(Icons.bedtime_rounded, color: theme.accent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '今天是休息日，不需要打卡；连续成长记录会保留。',
              style: TextStyle(color: theme.text, fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    ),
  );
}

class _SyncNotice extends StatelessWidget {
  const _SyncNotice({required this.text, required this.theme});
  final String text;
  final _CatTheme theme;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.surface.withValues(alpha: .78),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Text(
          text,
          style: TextStyle(color: theme.text, fontWeight: FontWeight.w400),
        ),
      ),
    );
  }
}

class _StarFlight extends StatelessWidget {
  const _StarFlight({
    super.key,
    required this.animation,
    required this.start,
    required this.end,
    required this.color,
  });
  final Animation<double> animation;
  final Offset start;
  final Offset end;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final progress = animation.value;
        final eased = Curves.easeOutCubic.transform(progress);
        final control = Offset(
          (start.dx + end.dx) / 2,
          math.min(start.dy, end.dy) - 86,
        );
        final position = _quadratic(start, control, end, eased);
        // Positioned must apply its layout data to a direct child of Stack.
        // IgnorePointer belongs INSIDE it, never between Positioned and Stack.
        // Keep the positioned child present at both endpoints to avoid relayout.
        return Positioned(
          left: position.dx - 16,
          top: position.dy - 16,
          child: IgnorePointer(
            child: Opacity(
              opacity: progress == 0 || progress == 1 ? 0 : 1,
              child: Transform.rotate(
                angle: math.pi * eased,
                child: Icon(Icons.star_rounded, color: color, size: 32),
              ),
            ),
          ),
        );
      },
    );
  }

  Offset _quadratic(Offset a, Offset b, Offset c, double t) {
    final inverse = 1 - t;
    return Offset(
      inverse * inverse * a.dx + 2 * inverse * t * b.dx + t * t * c.dx,
      inverse * inverse * a.dy + 2 * inverse * t * b.dy + t * t * c.dy,
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('重试')),
          ],
        ),
      ),
    );
  }
}

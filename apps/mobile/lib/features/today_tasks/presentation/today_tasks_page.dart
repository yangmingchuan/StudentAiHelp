import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:little_hero/core/theme/app_theme.dart';
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
  Offset? _starFlightStart;
  Offset? _starFlightEnd;
  int _starFlightId = 0;

  @override
  void initState() {
    super.initState();
    _starController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 980),
    );
  }

  @override
  void dispose() {
    _starController.dispose();
    super.dispose();
  }

  Future<void> _completeTask(
    TaskSummary task,
    BuildContext sourceContext,
  ) async {
    if (task.isDone) return;

    final start = _centerInPage(sourceContext);
    final end = _centerForKey(_starTargetKey);

    await ref
        .read(homeControllerProvider.notifier)
        .setTaskStatus(task.id, TaskStatus.done);
    if (!mounted) return;

    final didComplete =
        ref
            .read(homeControllerProvider)
            .asData
            ?.value
            .tasks
            .any((item) => item.id == task.id && item.isDone) ??
        false;
    if (!didComplete) return;

    final fallbackStart = Offset(MediaQuery.sizeOf(context).width - 52, 260);
    final fallbackEnd = Offset(MediaQuery.sizeOf(context).width * 0.18, 112);
    setState(() {
      _starFlightStart = start ?? fallbackStart;
      _starFlightEnd = end ?? fallbackEnd;
      _starFlightId += 1;
    });
    _starController.forward(from: 0);
  }

  Offset? _centerForKey(GlobalKey key) {
    final targetContext = key.currentContext;
    if (targetContext == null) return null;
    return _centerInPage(targetContext);
  }

  Offset? _centerInPage(BuildContext childContext) {
    final childObject = childContext.findRenderObject();
    final pageObject = _pageKey.currentContext?.findRenderObject();
    if (childObject is! RenderBox || pageObject is! RenderBox) return null;
    if (!childObject.attached || !pageObject.attached) return null;

    final globalCenter = childObject.localToGlobal(
      childObject.size.center(Offset.zero),
    );
    return pageObject.globalToLocal(globalCenter);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeControllerProvider);

    return state.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _ErrorView(
        message: error.toString(),
        onRetry: () => ref.read(homeControllerProvider.notifier).refresh(),
      ),
      data: (snapshot) => Stack(
        key: _pageKey,
        clipBehavior: Clip.none,
        children: [
          RefreshIndicator(
            onRefresh: () =>
                ref.read(homeControllerProvider.notifier).refresh(),
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
                  sliver: SliverList.list(
                    children: [
                      _HomeHeading(
                        title: '${snapshot.child.nickname}，今天也要加油',
                        subtitle: snapshot.isStale
                            ? '当前显示本地缓存，网络恢复后会自动同步'
                            : '完成一个小任务，收获一颗成长星星',
                      ),
                      const SizedBox(height: 20),
                      _AssetStrip(
                        assets: snapshot.assets,
                        starTargetKey: _starTargetKey,
                      ),
                      if (snapshot.isSyncing || snapshot.message != null) ...[
                        const SizedBox(height: 12),
                        _SyncNotice(
                          text: snapshot.isSyncing
                              ? '正在同步今天的变化'
                              : snapshot.message!,
                        ),
                      ],
                    ],
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
                  sliver: SliverList.separated(
                    itemCount: snapshot.tasks.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final task = snapshot.tasks[index];
                      return _TaskTile(
                        task: task,
                        color: _taskColor(index),
                        onDone: (sourceContext) =>
                            _completeTask(task, sourceContext),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          if (_starFlightStart != null && _starFlightEnd != null)
            _StarFlightOverlay(
              key: ValueKey(_starFlightId),
              animation: _starController,
              start: _starFlightStart!,
              end: _starFlightEnd!,
            ),
        ],
      ),
    );
  }

  Color _taskColor(int index) {
    const colors = [AppColors.blue, AppColors.green, AppColors.coral];
    return colors[index % colors.length];
  }
}

class _StarFlightOverlay extends StatelessWidget {
  const _StarFlightOverlay({
    super.key,
    required this.animation,
    required this.start,
    required this.end,
  });

  final Animation<double> animation;
  final Offset start;
  final Offset end;

  static const _starOffsets = [
    Offset(-20, -4),
    Offset(-10, 14),
    Offset(0, -18),
    Offset(13, 8),
    Offset(22, -12),
    Offset(31, 12),
    Offset(-30, 12),
  ];

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final progress = animation.value;
          if (progress == 0 || progress == 1) {
            return const SizedBox.shrink();
          }

          return Stack(
            clipBehavior: Clip.none,
            children: [
              for (var index = 0; index < _starOffsets.length; index++)
                _FlyingStar(
                  progress: progress,
                  start: start + _starOffsets[index],
                  end: end + Offset((index - 3) * 3, index.isEven ? -4 : 4),
                  arcHeight: 82 + (index % 3) * 22,
                  delay: index * 0.045,
                  size: 18 + (index % 3) * 3,
                  clockwise: index.isEven,
                ),
            ],
          );
        },
      ),
    );
  }
}

class _FlyingStar extends StatelessWidget {
  const _FlyingStar({
    required this.progress,
    required this.start,
    required this.end,
    required this.arcHeight,
    required this.delay,
    required this.size,
    required this.clockwise,
  });

  final double progress;
  final Offset start;
  final Offset end;
  final double arcHeight;
  final double delay;
  final double size;
  final bool clockwise;

  @override
  Widget build(BuildContext context) {
    const span = 0.74;
    final raw = ((progress - delay) / span).clamp(0.0, 1.0);
    if (raw <= 0 || raw >= 1) return const SizedBox.shrink();

    final eased = Curves.easeOutCubic.transform(raw);
    final control = Offset(
      (start.dx + end.dx) / 2,
      math.min(start.dy, end.dy) - arcHeight,
    );
    final position = _quadratic(start, control, end, eased);
    final fadeOut = Curves.easeIn.transform((1 - raw).clamp(0.0, 1.0));
    final fadeIn = (raw / 0.18).clamp(0.0, 1.0);
    final scale = 0.7 + 0.45 * math.sin(math.pi * raw);

    return Positioned(
      left: position.dx - size / 2,
      top: position.dy - size / 2,
      child: Opacity(
        opacity: math.min(fadeIn, fadeOut),
        child: Transform.rotate(
          angle: (clockwise ? 1 : -1) * math.pi * eased,
          child: Transform.scale(
            scale: scale,
            child: Icon(
              Icons.star_rounded,
              color: AppColors.orange,
              size: size,
            ),
          ),
        ),
      ),
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

class _HomeHeading extends StatelessWidget {
  const _HomeHeading({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.ink,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            height: 1.18,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.ink,
            fontSize: 16,
            fontWeight: FontWeight.w400,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _AssetStrip extends StatelessWidget {
  const _AssetStrip({required this.assets, required this.starTargetKey});

  final AssetSummary assets;
  final GlobalKey starTargetKey;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _AssetChip(
            key: starTargetKey,
            icon: Icons.star_rounded,
            value: assets.availableStars.toString(),
            color: AppColors.orange,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _AssetChip(
            icon: Icons.workspace_premium_rounded,
            value: assets.badgeCount.toString(),
            color: AppColors.green,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _AssetChip(
            icon: Icons.favorite_rounded,
            value: '${assets.heartsRemaining}/${assets.heartsLimit}',
            color: AppColors.coral,
          ),
        ),
      ],
    );
  }
}

class _AssetChip extends StatelessWidget {
  const _AssetChip({
    super.key,
    required this.icon,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
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
    required this.color,
    required this.onDone,
  });

  final TaskSummary task;
  final Color color;
  final ValueChanged<BuildContext> onDone;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(16),
              ),
              child: SizedBox(
                width: 48,
                height: 48,
                child: Icon(_iconFor(task.iconName), color: color, size: 28),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                task.name,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 19,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Builder(
              builder: (buttonContext) => IconButton.filledTonal(
                tooltip: task.isDone ? '已完成' : '完成',
                onPressed: task.isDone ? null : () => onDone(buttonContext),
                style: IconButton.styleFrom(
                  backgroundColor: task.isDone
                      ? AppColors.green.withValues(alpha: 0.24)
                      : null,
                ),
                icon: Icon(
                  task.isDone ? Icons.task_alt_rounded : Icons.check_rounded,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(String iconName) {
    return switch (iconName) {
      'clean_hands_rounded' => Icons.clean_hands_rounded,
      'bed_rounded' => Icons.bed_rounded,
      'auto_stories_rounded' => Icons.auto_stories_rounded,
      _ => Icons.task_alt_rounded,
    };
  }
}

class _SyncNotice extends StatelessWidget {
  const _SyncNotice({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.blue.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Text(
          text,
          style: const TextStyle(
            color: AppColors.ink,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
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

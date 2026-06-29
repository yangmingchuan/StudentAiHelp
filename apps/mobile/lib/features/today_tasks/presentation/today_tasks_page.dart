import 'package:flutter/material.dart';
import 'package:little_hero/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:little_hero/features/today_tasks/application/home_controller.dart';
import 'package:little_hero/features/today_tasks/domain/home_snapshot.dart';

class TodayTasksPage extends ConsumerWidget {
  const TodayTasksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeControllerProvider);

    return state.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _ErrorView(
        message: error.toString(),
        onRetry: () => ref.read(homeControllerProvider.notifier).refresh(),
      ),
      data: (snapshot) => RefreshIndicator(
        onRefresh: () => ref.read(homeControllerProvider.notifier).refresh(),
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
                  _AssetStrip(assets: snapshot.assets),
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
                    onDone: () => ref
                        .read(homeControllerProvider.notifier)
                        .setTaskStatus(task.id, TaskStatus.done),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _taskColor(int index) {
    const colors = [AppColors.blue, AppColors.green, AppColors.coral];
    return colors[index % colors.length];
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
  const _AssetStrip({required this.assets});

  final AssetSummary assets;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _AssetChip(
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
  final VoidCallback onDone;

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
            IconButton.filledTonal(
              tooltip: '完成',
              onPressed: onDone,
              style: IconButton.styleFrom(
                backgroundColor: task.isDone
                    ? AppColors.green.withValues(alpha: 0.24)
                    : null,
              ),
              icon: Icon(Icons.check_rounded),
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

import 'package:flutter/material.dart';
import 'package:little_hero/core/theme/app_theme.dart';
import 'package:little_hero/core/widgets/page_heading.dart';

class TodayTasksPage extends StatelessWidget {
  const TodayTasksPage({super.key});

  static const _tasks = [
    (Icons.clean_hands_rounded, '自己刷牙', AppColors.blue),
    (Icons.bed_rounded, '整理床铺', AppColors.green),
    (Icons.auto_stories_rounded, '阅读绘本', AppColors.coral),
  ];

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
          sliver: SliverList.list(
            children: const [
              PageHeading(title: '今天也要加油', subtitle: '完成一个小任务，收获一颗成长星星'),
              SizedBox(height: 20),
              _AssetStrip(),
            ],
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
          sliver: SliverList.separated(
            itemCount: _tasks.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final task = _tasks[index];
              return _TaskTile(icon: task.$1, title: task.$2, color: task.$3);
            },
          ),
        ),
      ],
    );
  }
}

class _AssetStrip extends StatelessWidget {
  const _AssetStrip();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: _AssetChip(
            icon: Icons.star_rounded,
            label: '星星',
            value: '0',
            color: AppColors.orange,
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _AssetChip(
            icon: Icons.workspace_premium_rounded,
            label: '勋章',
            value: '0',
            color: AppColors.green,
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _AssetChip(
            icon: Icons.favorite_rounded,
            label: '心心',
            value: '10',
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
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              '$value $label',
              maxLines: 1,
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 16,
                fontWeight: FontWeight.w800,
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
    required this.icon,
    required this.title,
    required this.color,
  });

  final IconData icon;
  final String title;
  final Color color;

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
                child: Icon(icon, color: color, size: 28),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(title, style: Theme.of(context).textTheme.titleLarge),
            ),
            IconButton.filledTonal(
              tooltip: '完成',
              onPressed: () {},
              icon: const Icon(Icons.check_rounded),
            ),
            const SizedBox(width: 6),
            IconButton.outlined(
              tooltip: '跳过',
              onPressed: () {},
              icon: const Icon(Icons.remove_rounded),
            ),
          ],
        ),
      ),
    );
  }
}

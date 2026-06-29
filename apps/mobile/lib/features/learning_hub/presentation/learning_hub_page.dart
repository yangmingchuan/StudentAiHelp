import 'package:flutter/material.dart';
import 'package:little_hero/core/theme/app_theme.dart';
import 'package:little_hero/core/widgets/page_heading.dart';

class LearningHubPage extends StatelessWidget {
  const LearningHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
      children: const [
        PageHeading(title: '学习乐园', subtitle: '数学小岛和英语森林正在准备中'),
        SizedBox(height: 22),
        _LearningEntryCard(
          title: '数学小岛',
          subtitle: '数数、比较、加减、图形',
          message: '内容准备中',
          icon: Icons.calculate_rounded,
          color: AppColors.blue,
        ),
        SizedBox(height: 14),
        _LearningEntryCard(
          title: '英语森林',
          subtitle: '字母、单词、儿歌、绘本',
          message: '内容准备中',
          icon: Icons.menu_book_rounded,
          color: AppColors.green,
        ),
      ],
    );
  }
}

class _LearningEntryCard extends StatelessWidget {
  const _LearningEntryCard({
    required this.title,
    required this.subtitle,
    required this.message,
    required this.icon,
    required this.color,
  });

  final String title;
  final String subtitle;
  final String message;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(20),
              ),
              child: SizedBox(
                width: 64,
                height: 64,
                child: Icon(icon, color: color, size: 34),
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.ink.withValues(alpha: 0.68),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    style: TextStyle(color: color, fontWeight: FontWeight.w900),
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

import 'package:flutter/material.dart';
import 'package:little_hero/core/theme/app_theme.dart';
import 'package:little_hero/features/shared/presentation/learning_placeholder_page.dart';

class MathPlaceholderPage extends StatelessWidget {
  const MathPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const LearningPlaceholderPage(
      title: '数学岛',
      message: '关卡正在准备中',
      detail: 'MVP 暂不消耗小心心，也不会加载题库。',
      icon: Icons.calculate_rounded,
      accentColor: AppColors.blue,
    );
  }
}

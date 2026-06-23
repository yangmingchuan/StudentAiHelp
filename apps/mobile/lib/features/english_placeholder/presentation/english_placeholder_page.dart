import 'package:flutter/material.dart';
import 'package:little_hero/core/theme/app_theme.dart';
import 'package:little_hero/features/shared/presentation/learning_placeholder_page.dart';

class EnglishPlaceholderPage extends StatelessWidget {
  const EnglishPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const LearningPlaceholderPage(
      title: '英语森林',
      message: '内容正在准备中',
      detail: 'MVP 暂不加载音频、单词、描边或绘本。',
      icon: Icons.menu_book_rounded,
      accentColor: AppColors.green,
    );
  }
}

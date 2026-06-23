import 'package:flutter/material.dart';
import 'package:little_hero/core/theme/app_theme.dart';
import 'package:little_hero/core/widgets/page_heading.dart';

class LearningPlaceholderPage extends StatelessWidget {
  const LearningPlaceholderPage({
    required this.title,
    required this.message,
    required this.detail,
    required this.icon,
    required this.accentColor,
    super.key,
  });

  final String title;
  final String message;
  final String detail;
  final IconData icon;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeading(title: title, subtitle: '新的冒险会在后续阶段开放'),
          const Spacer(),
          Align(
            alignment: const Alignment(0.2, 0),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: accentColor.withValues(alpha: 0.35),
                  width: 2,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: accentColor, size: 72),
                    const SizedBox(height: 20),
                    Text(
                      message,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      detail,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.ink.withValues(alpha: 0.68),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}

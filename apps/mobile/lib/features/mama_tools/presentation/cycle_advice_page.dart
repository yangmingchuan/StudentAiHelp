import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:little_hero/core/theme/app_theme.dart';
import 'package:little_hero/features/mama_tools/application/cycle_controller.dart';
import 'package:little_hero/features/mama_tools/domain/cycle_models.dart';

class CycleAdvicePage extends ConsumerWidget {
  const CycleAdvicePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cycleControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('每日建议')),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (snapshot) {
          final day = snapshot.selectedDay;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '今日概况',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          Text(
                            '${day.date.month}月${day.date.day}日',
                            style: TextStyle(
                              color: AppColors.ink.withValues(alpha: 0.52),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.orange.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                day.summary,
                                style: const TextStyle(
                                  color: AppColors.ink,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '预测易孕概率约 ${day.fertilityLabel}',
                                style: TextStyle(
                                  color: AppColors.ink.withValues(alpha: 0.58),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _AdviceCard(
                marker: '宜',
                color: AppColors.orange,
                text: day.advice,
              ),
              const SizedBox(height: 12),
              _AdviceCard(
                marker: '忌',
                color: AppColors.coral,
                text: _avoidanceText(day.phase.label),
              ),
              const SizedBox(height: 14),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Text(
                    '预测来自经期开始日、持续天数和周期长度。若周期长期不规律、疼痛剧烈、出血异常或疑似怀孕，请咨询医生。',
                    style: TextStyle(
                      color: AppColors.ink.withValues(alpha: 0.66),
                      fontWeight: FontWeight.w700,
                      height: 1.55,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _avoidanceText(String phaseLabel) {
    return switch (phaseLabel) {
      '月经期' || '预测月经期' => '避免过度劳累、剧烈运动和长时间受凉。若今天不舒服，可以减少安排。',
      '排卵期' || '易孕日' => '不要把预测当作避孕依据；如有避孕或备孕计划，请使用更可靠的方式确认。',
      '黄体期' => '尽量少熬夜，减少高糖和高盐饮食，留意情绪与睡眠变化。',
      '易瘦期' => '不要突然加大运动强度，保持舒适、可持续的节奏。',
      _ => '避免忽视身体信号。轻微变化可以记录到身体日记里，方便之后回顾。',
    };
  }
}

class _AdviceCard extends StatelessWidget {
  const _AdviceCard({
    required this.marker,
    required this.color,
    required this.text,
  });

  final String marker;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              marker,
              style: TextStyle(
                color: color,
                fontSize: 34,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 1.55,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

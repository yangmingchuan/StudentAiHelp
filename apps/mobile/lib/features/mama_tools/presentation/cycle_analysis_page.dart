import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:little_hero/core/theme/app_theme.dart';
import 'package:little_hero/features/mama_tools/application/cycle_controller.dart';

class CycleAnalysisPage extends ConsumerWidget {
  const CycleAnalysisPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cycleControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('经期健康分析')),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (snapshot) {
          final profile = snapshot.profile;
          if (profile == null) {
            return const Center(child: Text('请先完成妈妈工具初始化'));
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.monitor_heart_rounded,
                            color: AppColors.orange,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '经期健康分',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: SizedBox(
                          width: 190,
                          height: 190,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              CircularProgressIndicator(
                                value: snapshot.healthScore / 100,
                                strokeWidth: 18,
                                strokeCap: StrokeCap.round,
                                backgroundColor: AppColors.orange.withValues(
                                  alpha: 0.12,
                                ),
                                color: AppColors.orange,
                              ),
                              Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      snapshot.healthScore.toString(),
                                      style: const TextStyle(
                                        color: AppColors.orange,
                                        fontSize: 52,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const Text(
                                      '生活参考',
                                      style: TextStyle(
                                        color: AppColors.ink,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '本周期：${_formatDateLabel(profile.lastPeriodStartDate)} 起，'
                        '周期 ${profile.cycleLengthDays} 天，经期 ${profile.periodLengthDays} 天。',
                        style: TextStyle(
                          color: AppColors.ink.withValues(alpha: 0.72),
                          fontWeight: FontWeight.w700,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _ScoreBreakdown(
                label: '规律及天数',
                value:
                    profile.cycleLengthDays >= 24 &&
                        profile.cycleLengthDays <= 35
                    ? 100
                    : 70,
                color: AppColors.orange,
              ),
              const SizedBox(height: 10),
              _ScoreBreakdown(
                label: '经期健康度',
                value:
                    profile.periodLengthDays >= 3 &&
                        profile.periodLengthDays <= 7
                    ? 100
                    : 72,
                color: AppColors.coral,
              ),
              const SizedBox(height: 10),
              _ScoreBreakdown(
                label: '记录完整度',
                value: snapshot.selectedDay.hasDiary ? 90 : 62,
                color: AppColors.green,
              ),
              const SizedBox(height: 14),
              Card(
                color: AppColors.orange.withValues(alpha: 0.1),
                child: const Padding(
                  padding: EdgeInsets.all(18),
                  child: Text(
                    '提醒：分析根据您近期记录估算得出，请勿视作医疗建议。补充疼痛程度、经血流量和身体日记后，分析会更有参考价值。',
                    style: TextStyle(
                      color: AppColors.ink,
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
}

class _ScoreBreakdown extends StatelessWidget {
  const _ScoreBreakdown({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
                Text(
                  '$value分',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ],
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: value / 100,
              minHeight: 10,
              borderRadius: BorderRadius.circular(999),
              backgroundColor: color.withValues(alpha: 0.13),
              color: color,
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDateLabel(DateTime value) {
  return '${value.month}月${value.day}日';
}

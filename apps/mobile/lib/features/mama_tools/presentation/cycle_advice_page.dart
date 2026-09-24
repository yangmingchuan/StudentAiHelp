import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:little_hero/features/mama_tools/application/cycle_controller.dart';
import 'package:little_hero/features/mama_tools/presentation/cycle_widgets.dart';

class CycleAdvicePage extends ConsumerWidget {
  const CycleAdvicePage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => CycleScene(
    title: '照顾自己',
    child: ref
        .watch(cycleControllerProvider)
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const Center(child: Text('暂时无法读取提醒')),
          data: (snapshot) => ListView(
            padding: cyclePagePadding(context),
            children: [
              CycleCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${cycleDateLabel(snapshot.selectedDate)} · 所选日期',
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      snapshot.selectedDay.summary,
                      style: const TextStyle(fontSize: 20, color: cycleRose),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      snapshot.selectedDay.advice,
                      style: const TextStyle(height: 1.6),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              CycleCard(
                child: Row(
                  children: [
                    Image.asset(
                      'assets/task_icons/emotion.png',
                      width: 64,
                      height: 64,
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Text(
                        '不需要每一天都状态满分。\n按自己的感受安排休息与活动。',
                        style: TextStyle(height: 1.6),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const CycleCard(
                child: Text(
                  '这些内容用于日常记录与生活提醒。经期预测基于你填写的日期与周期长度，可能与实际不同，不用于避孕、妊娠判断或疾病诊断。若不适明显或持续，请咨询医生。',
                  style: TextStyle(fontSize: 13, height: 1.6),
                ),
              ),
            ],
          ),
        ),
  );
}

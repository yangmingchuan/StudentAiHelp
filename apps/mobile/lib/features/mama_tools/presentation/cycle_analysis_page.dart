import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:little_hero/features/mama_tools/application/cycle_controller.dart';
import 'package:little_hero/features/mama_tools/data/cycle_repository.dart';
import 'package:little_hero/features/mama_tools/presentation/cycle_widgets.dart';

class CycleAnalysisPage extends ConsumerWidget {
  const CycleAnalysisPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => CycleScene(
    title: '记录回顾',
    child: ref
        .watch(cycleControllerProvider)
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const Center(child: Text('暂时无法读取记录')),
          data: (snapshot) => ListView(
            padding: cyclePagePadding(context),
            children: [
              CycleCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('你的记录，慢慢积累', style: TextStyle(fontSize: 20)),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 24,
                      runSpacing: 12,
                      children: [
                        Text(
                          '已记录 ${snapshot.records.length} 天',
                          style: const TextStyle(
                            fontSize: 18,
                            color: cycleRose,
                          ),
                        ),
                        Text(
                          '有经量记录 ${snapshot.records.where((d) => d.flow.isBleeding).length} 天',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '这里展示实际记录，不给身体打分。',
                      style: TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (snapshot.records.isEmpty)
                CycleCard(
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/task_icons/reading.png',
                        width: 80,
                        height: 80,
                      ),
                      const SizedBox(height: 12),
                      const Text('还没有每日记录'),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () => context.push(
                          '/mama/diary/${cycleDateKey(snapshot.today)}',
                        ),
                        child: const Text('写下今天的感受'),
                      ),
                    ],
                  ),
                ),
              for (final day in snapshot.records)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: CycleCard(
                    padding: EdgeInsets.zero,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                      title: Text(cycleDateLabel(day.date)),
                      subtitle: Text(
                        [
                          if (day.flow.value != 'none') day.flow.label,
                          ...day.symptoms,
                          if (day.hasDiary) day.diaryText,
                        ].join(' · '),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () =>
                          context.push('/mama/diary/${cycleDateKey(day.date)}'),
                    ),
                  ),
                ),
            ],
          ),
        ),
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:little_hero/features/mama_tools/application/cycle_controller.dart';
import 'package:little_hero/features/mama_tools/data/cycle_repository.dart';
import 'package:little_hero/features/mama_tools/domain/cycle_models.dart';
import 'package:little_hero/features/mama_tools/presentation/cycle_widgets.dart';

class MamaToolsPage extends ConsumerWidget {
  const MamaToolsPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => CycleScene(
    child: ref
        .watch(cycleControllerProvider)
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => Center(
            child: CycleCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('暂时无法读取经期记录'),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => ref.invalidate(cycleControllerProvider),
                    child: const Text('重试'),
                  ),
                ],
              ),
            ),
          ),
          data: (snapshot) => snapshot.needsSetup
              ? const _Setup()
              : _CycleHome(snapshot: snapshot),
        ),
  );
}

class _Setup extends ConsumerStatefulWidget {
  const _Setup();
  @override
  ConsumerState<_Setup> createState() => _SetupState();
}

class _SetupState extends ConsumerState<_Setup> {
  DateTime? _start;
  int _period = 5, _cycle = 28;
  bool _saving = false;
  Future<void> _pick() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _start ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      helpText: '最近一次经期开始',
    );
    if (picked != null && mounted) setState(() => _start = picked);
  }

  Future<void> _save() async {
    if (_start == null) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(cycleControllerProvider.notifier)
          .saveSetup(
            CycleProfileDraft(
              lastPeriodStartDate: _start!,
              periodLengthDays: _period,
              cycleLengthDays: _cycle,
            ),
          );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(cycleErrorText(error))));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => ListView(
    padding: cyclePagePadding(context),
    children: [
      const CycleHeading(title: '经期手记', subtitle: '记录自己的节奏，好好照顾自己'),
      const SizedBox(height: 14),
      CycleCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('从最近一次经期开始', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 8),
            const Text(
              '填写三个信息，建立你的周期日历。',
              style: TextStyle(color: Color(0xFF786B72)),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.event_available_rounded,
                color: cycleRose,
              ),
              title: const Text('经期开始日期'),
              subtitle: Text(
                _start == null ? '请选择实际开始的日期' : cycleDateLabel(_start!),
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: _saving ? null : _pick,
            ),
            const Divider(height: 28),
            CycleNumberField(
              label: '通常经期持续',
              value: _period,
              min: 1,
              max: 15,
              onChanged: (v) => setState(() => _period = v),
            ),
            const Divider(height: 28),
            CycleNumberField(
              label: '通常周期长度',
              value: _cycle,
              min: 15,
              max: 90,
              onChanged: (v) => setState(() => _cycle = v),
            ),
            const Text(
              '周期长度：两次经期第一天之间的天数。不确定时可先保留默认值，之后随时调整。',
              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                color: Color(0xFF786B72),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving || _start == null ? null : _save,
                child: Text(_saving ? '保存中…' : '开启我的经期日历'),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      const CycleCard(
        child: Text(
          '记录会先保存在本机，登录后尝试同步到云端；同步状态可在「我的」查看。预测仅供日程参考，不用于避孕、怀孕判断或疾病诊断。',
          style: TextStyle(fontSize: 12, height: 1.5),
        ),
      ),
    ],
  );
}

class _CycleHome extends ConsumerWidget {
  const _CycleHome({required this.snapshot});
  final CycleSnapshot snapshot;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(cycleControllerProvider.notifier);
    final expected = snapshot.nextPeriodDate!;
    final remaining = cycleDaysBetween(expected, snapshot.today);
    final day = snapshot.selectedDay;
    final isFuture = day.date.isAfter(snapshot.today);
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: cyclePagePadding(context),
          sliver: SliverList.list(
            children: [
              const CycleHeading(title: '经期手记', subtitle: '每一个阶段，都值得被温柔对待'),
              const SizedBox(height: 12),
              CycleCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.spa_outlined,
                          color: cycleRose,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            '下一次经期 · 预计',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        IconButton(
                          tooltip: '周期设置',
                          onPressed: () => context.push('/mama/settings'),
                          icon: const Icon(Icons.tune_rounded),
                        ),
                      ],
                    ),
                    Text(
                      remaining > 0
                          ? '还有 $remaining 天'
                          : remaining == 0
                          ? '预计今天开始'
                          : '预计日期已过 ${-remaining} 天',
                      style: const TextStyle(fontSize: 27, color: cycleRose),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${cycleDateLabel(expected)} · 根据已填写的周期估算',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF786B72),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => context.push(
                          '/mama/diary/${cycleDateKey(snapshot.today)}',
                        ),
                        icon: const Icon(Icons.edit_calendar_rounded, size: 18),
                        label: const Text('记录今天'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _Calendar(
                snapshot: snapshot,
                previous: controller.previousMonth,
                next: controller.nextMonth,
                today: controller.goToToday,
                select: controller.selectDate,
              ),
              const SizedBox(height: 12),
              CycleCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${day.date.month}月${day.date.day}日 · ${day.phase.label}',
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                        Icon(
                          day.hasRecord
                              ? Icons.check_circle_outline
                              : Icons.edit_note,
                          color: cycleRose,
                          size: 22,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(day.summary, style: const TextStyle(fontSize: 14)),
                    if (day.symptoms.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(day.symptoms.join(' · ')),
                      ),
                    if (day.hasDiary)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          day.diaryText,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: isFuture
                          ? null
                          : () => context.push(
                              '/mama/diary/${cycleDateKey(day.date)}',
                            ),
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: Text(
                        isFuture
                            ? '未来日期仅展示预测'
                            : day.hasRecord
                            ? '编辑这一天'
                            : '记录这一天',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              CycleCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    ListTile(
                      leading: Image.asset(
                        'assets/task_icons/reading.png',
                        width: 42,
                        height: 42,
                      ),
                      title: const Text('记录回顾'),
                      subtitle: const Text('查看经量、感受与历史日记'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => context.push('/mama/analysis'),
                    ),
                    const Divider(height: 1, indent: 18, endIndent: 18),
                    ListTile(
                      leading: Image.asset(
                        'assets/task_icons/emotion.png',
                        width: 42,
                        height: 42,
                      ),
                      title: const Text('照顾自己'),
                      subtitle: const Text('身体感受与日常提醒'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => context.push('/mama/advice'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const CycleCard(
                child: Text(
                  '已记录和预测是两回事。预测不用于避孕或疾病诊断。',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Calendar extends StatelessWidget {
  const _Calendar({
    required this.snapshot,
    required this.previous,
    required this.next,
    required this.today,
    required this.select,
  });
  final CycleSnapshot snapshot;
  final VoidCallback previous, next, today;
  final ValueChanged<DateTime> select;
  @override
  Widget build(BuildContext context) => CycleCard(
    padding: const EdgeInsets.all(12),
    child: Column(
      children: [
        Row(
          children: [
            IconButton(
              tooltip: '上个月',
              onPressed: previous,
              icon: const Icon(Icons.chevron_left_rounded),
            ),
            Expanded(
              child: Text(
                '${snapshot.visibleMonth.year}年${snapshot.visibleMonth.month}月',
                style: const TextStyle(fontSize: 18),
              ),
            ),
            TextButton(onPressed: today, child: const Text('今天')),
            IconButton(
              tooltip: '下个月',
              onPressed: next,
              icon: const Icon(Icons.chevron_right_rounded),
            ),
          ],
        ),
        Row(
          children: [
            for (final name in ['日', '一', '二', '三', '四', '五', '六'])
              Expanded(
                child: Center(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF786B72),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.calendarDays.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 4,
            crossAxisSpacing: 2,
            mainAxisExtent: 44,
          ),
          itemBuilder: (context, index) {
            final day = snapshot.calendarDays[index];
            final recorded = day.info.phase == CyclePhase.menstrual;
            final predicted = day.info.phase == CyclePhase.predictedPeriod;
            return Semantics(
              button: true,
              selected: day.isSelected,
              label:
                  '${cycleDateLabel(day.date)}，${day.info.phase.label}${day.info.hasRecord ? '，有记录' : ''}',
              child: InkWell(
                onTap: () => select(day.date),
                borderRadius: BorderRadius.circular(13),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(13),
                    color: recorded
                        ? cycleRose
                        : predicted
                        ? const Color(0xFFF9E3EB)
                        : Colors.transparent,
                    border: Border.all(
                      color: day.isSelected
                          ? const Color(0xFF265A50)
                          : predicted
                          ? cycleRose.withValues(alpha: .3)
                          : Colors.transparent,
                      width: day.isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '${day.date.day}',
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.1,
                            color: recorded
                                ? Colors.white
                                : day.isInVisibleMonth
                                ? cycleInk
                                : const Color(0xFF94858C),
                          ),
                        ),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          day.isToday
                              ? '今天'
                              : day.info.hasRecord
                              ? '·'
                              : predicted
                              ? '预'
                              : '',
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 9,
                            height: 1.05,
                            color: recorded ? Colors.white : cycleRose,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        const Wrap(
          spacing: 14,
          runSpacing: 4,
          children: [
            Text('● 已记录经期', style: TextStyle(color: cycleRose, fontSize: 11)),
            Text('预  预测经期', style: TextStyle(color: cycleRose, fontSize: 11)),
            Text('· 有日记或感受', style: TextStyle(fontSize: 11)),
          ],
        ),
      ],
    ),
  );
}

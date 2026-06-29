import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:little_hero/core/theme/app_theme.dart';
import 'package:little_hero/features/mama_tools/application/cycle_controller.dart';
import 'package:little_hero/features/mama_tools/domain/cycle_models.dart';

class MamaToolsPage extends ConsumerWidget {
  const MamaToolsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cycleControllerProvider);

    return state.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _MamaErrorView(
        message: error.toString(),
        onRetry: () => ref.invalidate(cycleControllerProvider),
      ),
      data: (snapshot) {
        if (snapshot.needsSetup) {
          return _CycleSetupView(snapshot: snapshot);
        }
        return _CycleHomeView(snapshot: snapshot);
      },
    );
  }
}

class _CycleSetupView extends ConsumerStatefulWidget {
  const _CycleSetupView({required this.snapshot});

  final CycleSnapshot snapshot;

  @override
  ConsumerState<_CycleSetupView> createState() => _CycleSetupViewState();
}

class _CycleSetupViewState extends ConsumerState<_CycleSetupView> {
  late DateTime _lastPeriodStart;
  late DateTime _birthDate;
  int _periodLengthDays = 5;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _lastPeriodStart = DateTime(today.year, today.month, today.day);
    _birthDate = DateTime(today.year - 30, today.month, today.day);
  }

  Future<void> _pickLastPeriodStart() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _lastPeriodStart,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() => _lastPeriodStart = picked);
    }
  }

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      await ref
          .read(cycleControllerProvider.notifier)
          .saveSetup(
            CycleProfileDraft(
              lastPeriodStartDate: _lastPeriodStart,
              periodLengthDays: _periodLengthDays,
              cycleLengthDays: 28,
              birthDate: _birthDate,
            ),
          );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
      children: [
        const _MamaHeader(title: '妈妈工具', subtitle: '先填一点基础信息，日历会开始预测'),
        const SizedBox(height: 18),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('首次设置', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  '数据会先保存在本机。经期预测只用于生活提醒，不作为医学、避孕或妊娠判断依据。',
                  style: TextStyle(
                    color: AppColors.ink.withValues(alpha: 0.66),
                    fontWeight: FontWeight.w600,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 18),
                _PickerTile(
                  icon: Icons.event_available_rounded,
                  label: '最近一次经期开始',
                  value: _formatDateLabel(_lastPeriodStart),
                  onTap: _pickLastPeriodStart,
                ),
                const SizedBox(height: 12),
                _StepperTile(
                  icon: Icons.timelapse_rounded,
                  label: '一般经期持续天数',
                  value: '$_periodLengthDays天',
                  onMinus: _periodLengthDays <= 2
                      ? null
                      : () => setState(() => _periodLengthDays -= 1),
                  onPlus: _periodLengthDays >= 10
                      ? null
                      : () => setState(() => _periodLengthDays += 1),
                ),
                const SizedBox(height: 12),
                _PickerTile(
                  icon: Icons.cake_rounded,
                  label: '妈妈出生年月日',
                  value: _formatDateLabel(_birthDate),
                  onTap: _pickBirthDate,
                ),
                const SizedBox(height: 18),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(14),
                    child: Text(
                      '月经周期长度先按 28 天计算，之后可在设置里修改。',
                      style: TextStyle(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isSaving ? null : _save,
                    child: Text(_isSaving ? '保存中...' : '开始使用妈妈工具'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CycleHomeView extends ConsumerWidget {
  const _CycleHomeView({required this.snapshot});

  final CycleSnapshot snapshot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(cycleControllerProvider.notifier);
    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(child: _MamaTabTitle()),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
          sliver: SliverList.list(
            children: [
              _CalendarCard(
                snapshot: snapshot,
                onPreviousMonth: controller.previousMonth,
                onNextMonth: controller.nextMonth,
                onSelectDate: controller.selectDate,
              ),
              const SizedBox(height: 6),
              _DayDetailPanel(day: snapshot.selectedDay),
              const SizedBox(height: 14),
              _ActionList(healthScore: snapshot.healthScore),
            ],
          ),
        ),
      ],
    );
  }
}

class _MamaTabTitle extends StatelessWidget {
  const _MamaTabTitle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
      child: Text(
        '妈妈',
        style: const TextStyle(
          color: AppColors.ink,
          fontSize: 24,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _CalendarCard extends StatelessWidget {
  const _CalendarCard({
    required this.snapshot,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onSelectDate,
  });

  final CycleSnapshot snapshot;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<DateTime> onSelectDate;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_month_rounded),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${snapshot.visibleMonth.year}年${snapshot.visibleMonth.month}月',
                    style: const TextStyle(
                      color: AppColors.ink,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: '上个月',
                  onPressed: onPreviousMonth,
                  icon: const Icon(Icons.chevron_left_rounded),
                ),
                IconButton(
                  tooltip: '下个月',
                  onPressed: onNextMonth,
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const _WeekHeader(),
            const SizedBox(height: 6),
            GridView.builder(
              itemCount: snapshot.calendarDays.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                childAspectRatio: 1.04,
              ),
              itemBuilder: (context, index) {
                final day = snapshot.calendarDays[index];
                return _CalendarDayCell(
                  day: day,
                  onTap: () => onSelectDate(day.date),
                );
              },
            ),
            const SizedBox(height: 10),
            const _CalendarLegend(),
          ],
        ),
      ),
    );
  }
}

class _WeekHeader extends StatelessWidget {
  const _WeekHeader();

  @override
  Widget build(BuildContext context) {
    const labels = ['日', '一', '二', '三', '四', '五', '六'];
    return Row(
      children: [
        for (final label in labels)
          Expanded(
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: label == '一'
                      ? AppColors.orange
                      : AppColors.ink.withValues(alpha: 0.48),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _CalendarDayCell extends StatelessWidget {
  const _CalendarDayCell({required this.day, required this.onTap});

  final CycleCalendarDay day;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = _phaseColor(day.info.phase);
    final background =
        day.info.phase == CyclePhase.predictedPeriod ||
            day.info.phase == CyclePhase.menstrual
        ? color.withValues(alpha: 0.18)
        : Colors.transparent;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: day.isSelected ? color.withValues(alpha: 0.2) : background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: day.isSelected ? color : Colors.transparent,
            width: day.isSelected ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(2, 2, 2, 2),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      day.date.day.toString(),
                      maxLines: 1,
                      style: TextStyle(
                        color: day.isInVisibleMonth
                            ? color
                            : AppColors.ink.withValues(alpha: 0.24),
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 12,
                child: day.isToday
                    ? const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '今天',
                          maxLines: 1,
                          style: TextStyle(
                            color: AppColors.orange,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            height: 1,
                          ),
                        ),
                      )
                    : day.info.hasDiary
                    ? Icon(Icons.edit_note_rounded, size: 12, color: color)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayDetailPanel extends StatelessWidget {
  const _DayDetailPanel({required this.day});

  final CycleDayInfo day;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${_formatDateLabel(day.date)} 详细说明',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Text(
                  '第${day.cycleDay}天',
                  style: TextStyle(
                    color: AppColors.ink.withValues(alpha: 0.56),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                for (final tag in day.tags)
                  Chip(
                    label: Text(tag),
                    backgroundColor: _phaseColor(
                      day.phase,
                    ).withValues(alpha: 0.12),
                    side: BorderSide.none,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            _DetailRow(
              label: '当前易孕概率',
              value: day.fertilityLabel,
              icon: Icons.favorite_rounded,
              color: AppColors.coral,
            ),
            const SizedBox(height: 8),
            Text(
              day.advice,
              style: TextStyle(
                color: AppColors.ink.withValues(alpha: 0.72),
                fontWeight: FontWeight.w600,
                height: 1.45,
              ),
            ),
            const Divider(height: 26),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: AppColors.orange.withValues(alpha: 0.14),
                child: const Icon(
                  Icons.edit_note_rounded,
                  color: AppColors.orange,
                ),
              ),
              title: const Text(
                '身体日记',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              subtitle: Text(
                day.hasDiary ? day.diaryText : '记录今天的身体感受，只支持文字',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.push('/mama/diary/${_formatDate(day.date)}'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionList extends StatelessWidget {
  const _ActionList({required this.healthScore});

  final int healthScore;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          _ActionTile(
            icon: Icons.monitor_heart_rounded,
            title: '经期健康分析',
            subtitle: '当前健康分 $healthScore，仅供生活参考',
            color: AppColors.coral,
            onTap: () => context.push('/mama/analysis'),
          ),
          const Divider(height: 1),
          _ActionTile(
            icon: Icons.lightbulb_rounded,
            title: '每日建议',
            subtitle: '根据当天阶段给出宜忌提醒',
            color: AppColors.orange,
            onTap: () => context.push('/mama/advice'),
          ),
          const Divider(height: 1),
          _ActionTile(
            icon: Icons.settings_rounded,
            title: '设置',
            subtitle: '修改生日、经期天数和周期长度',
            color: AppColors.blue,
            onTap: () => context.push('/mama/settings'),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.14),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _CalendarLegend extends StatelessWidget {
  const _CalendarLegend();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: const [
        _LegendItem(color: AppColors.orange, label: '月经/预测经期'),
        _LegendItem(color: Color(0xFFD36AEF), label: '排卵期'),
        _LegendItem(color: AppColors.green, label: '易孕日'),
        _LegendItem(color: AppColors.blue, label: '易瘦期'),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(999),
          ),
          child: const SizedBox(width: 18, height: 6),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _PickerTile extends StatelessWidget {
  const _PickerTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      tileColor: AppColors.orange.withValues(alpha: 0.08),
      leading: Icon(icon, color: AppColors.orange),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
      trailing: Text(
        value,
        style: const TextStyle(
          color: AppColors.orange,
          fontWeight: FontWeight.w900,
        ),
      ),
      onTap: onTap,
    );
  }
}

class _StepperTile extends StatelessWidget {
  const _StepperTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onMinus,
    required this.onPlus,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onMinus;
  final VoidCallback? onPlus;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.orange.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: AppColors.orange),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            IconButton(
              tooltip: '减少',
              onPressed: onMinus,
              icon: const Icon(Icons.remove_circle_outline_rounded),
            ),
            Text(
              value,
              style: const TextStyle(
                color: AppColors.orange,
                fontWeight: FontWeight.w900,
              ),
            ),
            IconButton(
              tooltip: '增加',
              onPressed: onPlus,
              icon: const Icon(Icons.add_circle_outline_rounded),
            ),
          ],
        ),
      ),
    );
  }
}

class _MamaHeader extends StatelessWidget {
  const _MamaHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.ink.withValues(alpha: 0.66),
          ),
        ),
      ],
    );
  }
}

class _MamaErrorView extends StatelessWidget {
  const _MamaErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('重试')),
          ],
        ),
      ),
    );
  }
}

Color _phaseColor(CyclePhase phase) {
  return switch (phase) {
    CyclePhase.menstrual || CyclePhase.predictedPeriod => AppColors.orange,
    CyclePhase.ovulation => const Color(0xFFD36AEF),
    CyclePhase.fertile => AppColors.green,
    CyclePhase.slim => AppColors.blue,
    CyclePhase.luteal => AppColors.coral,
    CyclePhase.normal => AppColors.ink,
    CyclePhase.setup => AppColors.ink,
  };
}

String _formatDate(DateTime value) {
  return '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}

String _formatDateLabel(DateTime value) {
  return '${value.year}年${value.month}月${value.day}日';
}

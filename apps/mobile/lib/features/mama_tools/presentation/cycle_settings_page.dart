import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:little_hero/core/theme/app_theme.dart';
import 'package:little_hero/features/mama_tools/application/cycle_controller.dart';
import 'package:little_hero/features/mama_tools/domain/cycle_models.dart';

class CycleSettingsPage extends ConsumerStatefulWidget {
  const CycleSettingsPage({super.key});

  @override
  ConsumerState<CycleSettingsPage> createState() => _CycleSettingsPageState();
}

class _CycleSettingsPageState extends ConsumerState<CycleSettingsPage> {
  DateTime? _lastPeriodStart;
  DateTime? _birthDate;
  int _periodLengthDays = 5;
  int _cycleLengthDays = 28;
  bool _initialized = false;
  bool _isSaving = false;

  void _initialize(CycleProfileSummary profile) {
    if (_initialized) {
      return;
    }
    _lastPeriodStart = profile.lastPeriodStartDate;
    _birthDate = profile.birthDate;
    _periodLengthDays = profile.periodLengthDays;
    _cycleLengthDays = profile.cycleLengthDays;
    _initialized = true;
  }

  Future<void> _pickDate({
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
    required ValueChanged<DateTime> onPicked,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (picked != null) {
      onPicked(picked);
    }
  }

  Future<void> _save() async {
    final lastPeriodStart = _lastPeriodStart;
    final birthDate = _birthDate;
    if (lastPeriodStart == null || birthDate == null) {
      return;
    }
    setState(() => _isSaving = true);
    try {
      await ref
          .read(cycleControllerProvider.notifier)
          .saveSettings(
            CycleProfileDraft(
              lastPeriodStartDate: lastPeriodStart,
              periodLengthDays: _periodLengthDays,
              cycleLengthDays: _cycleLengthDays,
              birthDate: birthDate,
            ),
          );
      if (mounted) {
        Navigator.pop(context);
      }
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
    final state = ref.watch(cycleControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: Text(_isSaving ? '保存中' : '保存'),
          ),
        ],
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (snapshot) {
          final profile = snapshot.profile;
          if (profile == null) {
            return const Center(child: Text('请先完成妈妈工具初始化'));
          }
          _initialize(profile);
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              _SettingTile(
                icon: Icons.event_available_rounded,
                title: '最近经期开始',
                value: _formatDateLabel(_lastPeriodStart!),
                onTap: () => _pickDate(
                  initialDate: _lastPeriodStart!,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                  onPicked: (date) => setState(() => _lastPeriodStart = date),
                ),
              ),
              const SizedBox(height: 10),
              _NumberSettingTile(
                icon: Icons.timelapse_rounded,
                title: '月经持续天数',
                value: '$_periodLengthDays天',
                onMinus: _periodLengthDays <= 2
                    ? null
                    : () => setState(() => _periodLengthDays -= 1),
                onPlus: _periodLengthDays >= 10
                    ? null
                    : () => setState(() => _periodLengthDays += 1),
              ),
              const SizedBox(height: 10),
              _NumberSettingTile(
                icon: Icons.calendar_view_month_rounded,
                title: '月经周期长度',
                value: '$_cycleLengthDays天',
                onMinus: _cycleLengthDays <= 21
                    ? null
                    : () => setState(() => _cycleLengthDays -= 1),
                onPlus: _cycleLengthDays >= 45
                    ? null
                    : () => setState(() => _cycleLengthDays += 1),
              ),
              const SizedBox(height: 10),
              _SettingTile(
                icon: Icons.cake_rounded,
                title: '生日',
                value: _formatDateLabel(_birthDate!),
                onTap: () => _pickDate(
                  initialDate: _birthDate!,
                  firstDate: DateTime(1950),
                  lastDate: DateTime.now(),
                  onPicked: (date) => setState(() => _birthDate = date),
                ),
              ),
              const SizedBox(height: 20),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    '智能预测会随本地记录持续修正。预测只作为生活提醒，不作为医学建议或避孕依据。',
                    style: TextStyle(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w700,
                      height: 1.45,
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

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppColors.orange),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: AppColors.orange,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}

class _NumberSettingTile extends StatelessWidget {
  const _NumberSettingTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onMinus,
    required this.onPlus,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback? onMinus;
  final VoidCallback? onPlus;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: AppColors.orange),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
            IconButton(
              tooltip: '减少',
              onPressed: onMinus,
              icon: const Icon(Icons.remove_circle_outline_rounded),
            ),
            SizedBox(
              width: 54,
              child: Text(
                value,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.orange,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
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

String _formatDateLabel(DateTime value) {
  return '${value.year}年${value.month}月${value.day}日';
}

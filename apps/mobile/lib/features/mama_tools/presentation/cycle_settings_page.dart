import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:little_hero/features/mama_tools/application/cycle_controller.dart';
import 'package:little_hero/features/mama_tools/domain/cycle_models.dart';
import 'package:little_hero/features/mama_tools/presentation/cycle_widgets.dart';

class CycleSettingsPage extends ConsumerStatefulWidget {
  const CycleSettingsPage({super.key});
  @override
  ConsumerState<CycleSettingsPage> createState() => _CycleSettingsPageState();
}

class _CycleSettingsPageState extends ConsumerState<CycleSettingsPage> {
  DateTime? _start;
  int _period = 5, _cycle = 28;
  bool _saving = false;
  Future<void> _save() async {
    if (_start == null) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(cycleControllerProvider.notifier)
          .saveSettings(
            CycleProfileDraft(
              lastPeriodStartDate: _start!,
              periodLengthDays: _period,
              cycleLengthDays: _cycle,
            ),
          );
      if (mounted) Navigator.pop(context);
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
  Widget build(BuildContext context) {
    final state = ref.watch(cycleControllerProvider);
    final profile = state.asData?.value.profile;
    if (_start == null && profile != null) {
      _start = profile.lastPeriodStartDate;
      _period = profile.periodLengthDays;
      _cycle = profile.cycleLengthDays;
    }
    return CycleScene(
      title: '周期设置',
      actions: [
        TextButton(
          onPressed: _saving || _start == null ? null : _save,
          child: Text(_saving ? '保存中' : '保存'),
        ),
      ],
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Center(child: Text('暂时无法读取设置')),
        data: (snapshot) => profile == null
            ? const Center(child: Text('请先完成经期设置'))
            : ListView(
                padding: cyclePagePadding(context),
                children: [
                  CycleCard(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.event_available_rounded,
                        color: cycleRose,
                      ),
                      title: const Text('最近一次经期开始'),
                      subtitle: Text(cycleDateLabel(_start!)),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: _saving
                          ? null
                          : () async {
                              final now = DateTime.now();
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _start!.isAfter(now)
                                    ? now
                                    : _start!,
                                firstDate: DateTime(2000),
                                lastDate: now,
                              );
                              if (date != null && mounted) {
                                setState(() => _start = date);
                              }
                            },
                    ),
                  ),
                  const SizedBox(height: 12),
                  CycleCard(
                    child: CycleNumberField(
                      label: '通常经期持续',
                      value: _period,
                      min: 1,
                      max: 15,
                      onChanged: (v) => setState(() => _period = v),
                    ),
                  ),
                  const SizedBox(height: 12),
                  CycleCard(
                    child: CycleNumberField(
                      label: '通常周期长度',
                      value: _cycle,
                      min: 15,
                      max: 90,
                      onChanged: (v) => setState(() => _cycle = v),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const CycleCard(
                    child: Text(
                      '周期长度是两次经期第一天之间的天数。预测按这些设置估算，不会自动推断身体是否健康，也不用于避孕。\n\n修改设置不会删除你已有的每日记录。',
                      style: TextStyle(height: 1.6, fontSize: 13),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

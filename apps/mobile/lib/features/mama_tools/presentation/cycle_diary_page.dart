import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:little_hero/features/mama_tools/application/cycle_controller.dart';
import 'package:little_hero/features/mama_tools/data/cycle_repository.dart';
import 'package:little_hero/features/mama_tools/domain/cycle_models.dart';
import 'package:little_hero/features/mama_tools/presentation/cycle_widgets.dart';

class CycleDiaryPage extends ConsumerStatefulWidget {
  const CycleDiaryPage({required this.date, super.key});
  final DateTime date;
  @override
  ConsumerState<CycleDiaryPage> createState() => _CycleDiaryPageState();
}

class _CycleDiaryPageState extends ConsumerState<CycleDiaryPage> {
  final _notes = TextEditingController();
  CycleFlow _flow = CycleFlow.unlogged;
  final Set<String> _symptoms = {};
  bool _initialized = false, _saving = false, _startsPeriod = false;
  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref
          .read(cycleControllerProvider.notifier)
          .saveRecord(
            date: widget.date,
            flow: _flow,
            symptoms: _symptoms.toList(),
            diaryText: _notes.text,
            startsPeriod: _startsPeriod,
          );
      ref.invalidate(cycleDayProvider(widget.date));
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
    final state = ref.watch(cycleDayProvider(widget.date));
    final data = state.asData?.value;
    if (data != null && !_initialized) {
      _notes.text = data.diaryText;
      _flow = data.flow;
      _symptoms.addAll(data.symptoms);
      _initialized = true;
    }
    final profile = ref.watch(cycleControllerProvider).asData?.value.profile;
    final future = cycleDateOnly(
      widget.date,
    ).isAfter(cycleDateOnly(DateTime.now()));
    return CycleScene(
      title: '${widget.date.month}月${widget.date.day}日记录',
      actions: [
        TextButton(
          onPressed: _saving || !_initialized || future ? null : _save,
          child: Text(_saving ? '保存中' : '保存'),
        ),
      ],
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: FilledButton(
            onPressed: () => ref.invalidate(cycleDayProvider(widget.date)),
            child: const Text('重新读取'),
          ),
        ),
        data: (day) => ListView(
          padding: cyclePagePadding(context),
          children: [
            CycleCard(
              child: Row(
                children: [
                  Image.asset(
                    'assets/task_icons/emotion.png',
                    width: 48,
                    height: 48,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      future ? '未来日期仅供查看预测' : '这一天的感受，都值得被记住。\n记录先保存在本机，登录后会尝试同步。',
                      style: const TextStyle(fontSize: 14, height: 1.6),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            CycleCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('经量', style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      for (final flow in CycleFlow.values)
                        ChoiceChip(
                          label: Text(flow.label),
                          selected: _flow == flow,
                          onSelected: _saving || future
                              ? null
                              : (_) => setState(() {
                                  _flow = flow;
                                  if (!flow.isBleeding) _startsPeriod = false;
                                }),
                        ),
                    ],
                  ),
                  if (profile != null &&
                      !widget.date.isBefore(profile.lastPeriodStartDate)) ...[
                    const Divider(height: 28),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        '本次经期从这天开始',
                        style: TextStyle(fontSize: 15),
                      ),
                      subtitle: const Text(
                        '开启后，将按这一天更新下次预计日期',
                        style: TextStyle(fontSize: 12),
                      ),
                      value: _startsPeriod,
                      onChanged: _saving || future || !_flow.isBleeding
                          ? null
                          : (v) => setState(() => _startsPeriod = v),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            CycleCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('身体与心情', style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      for (final symptom in <String>{
                        '腹部不适',
                        '疲倦',
                        '头痛',
                        '情绪波动',
                        '睡眠不好',
                        '状态不错',
                        ..._symptoms,
                      })
                        FilterChip(
                          label: Text(symptom),
                          selected: _symptoms.contains(symptom),
                          onSelected: _saving || future
                              ? null
                              : (selected) => setState(() {
                                  if (selected) {
                                    _symptoms.add(symptom);
                                  } else {
                                    _symptoms.remove(symptom);
                                  }
                                }),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            CycleCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('留一句话给自己', style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _notes,
                    enabled: !_saving && !future,
                    minLines: 4,
                    maxLines: 8,
                    maxLength: 500,
                    decoration: const InputDecoration(
                      hintText: '可以写下睡眠、疼痛或今天的小心情…',
                      border: InputBorder.none,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

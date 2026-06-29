import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:little_hero/core/theme/app_theme.dart';
import 'package:little_hero/features/mama_tools/application/cycle_controller.dart';

class CycleDiaryPage extends ConsumerStatefulWidget {
  const CycleDiaryPage({required this.date, super.key});

  final DateTime date;

  @override
  ConsumerState<CycleDiaryPage> createState() => _CycleDiaryPageState();
}

class _CycleDiaryPageState extends ConsumerState<CycleDiaryPage> {
  late final TextEditingController _controller;
  bool _initialized = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      await ref
          .read(cycleControllerProvider.notifier)
          .saveDiary(date: widget.date, diaryText: _controller.text);
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
        title: Text('${widget.date.month}月${widget.date.day}日身体日记'),
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
          if (!_initialized) {
            _controller.text = snapshot.selectedDay.diaryText;
            _initialized = true;
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    '只支持文字记录。可以写疼痛、情绪、睡眠、流量或今天的身体感受。',
                    style: TextStyle(
                      color: AppColors.ink.withValues(alpha: 0.72),
                      height: 1.45,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _controller,
                minLines: 10,
                maxLines: 16,
                maxLength: 500,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: '今天身体感觉怎么样？',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
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

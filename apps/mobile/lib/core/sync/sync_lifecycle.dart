import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:little_hero/features/today_tasks/application/home_controller.dart';
import 'package:little_hero/features/medication/application/medication_controller.dart';
import 'package:little_hero/features/medication/application/medication_reminder_notifications.dart';
import 'package:little_hero/features/medication/data/medication_repository.dart';
import 'package:little_hero/features/mama_tools/application/cycle_controller.dart';
import 'todo_sync_service.dart';

class SyncLifecycle extends ConsumerStatefulWidget {
  const SyncLifecycle({required this.child, super.key});
  final Widget child;
  @override
  ConsumerState<SyncLifecycle> createState() => _SyncLifecycleState();
}

class _SyncLifecycleState extends ConsumerState<SyncLifecycle>
    with WidgetsBindingObserver {
  StreamSubscription<void>? _updates;
  TodoSyncService? _service;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  void _attach(TodoSyncService? service) {
    if (identical(service, _service)) return;
    _service?.setActive(false);
    _updates?.cancel();
    _service = service;
    _updates = service?.updates.stream.listen(
      (_) => unawaited(_refreshViews()),
    );
    service?.setActive(true);
    if (service == null) {
      unawaited(
        ref
            .read(medicationReminderNotificationsProvider)
            .reconcile(const [])
            .catchError((Object error) {
              debugPrint('取消旧账号本地提醒失败: $error');
            }),
      );
    }
  }

  Future<void> _refreshViews() async {
    if (!mounted) return;
    await ref.read(homeControllerProvider.notifier).refreshLocal();
    if (!mounted) return;
    await ref.read(cycleControllerProvider.notifier).refresh();
    if (!mounted) return;
    await ref.read(medicationControllerProvider.notifier).refresh();
    if (!mounted) return;
    try {
      final reminders = await ref
          .read(medicationRepositoryProvider)
          .scheduledReminders();
      if (mounted) {
        await ref
            .read(medicationReminderNotificationsProvider)
            .reconcile(reminders);
      }
    } catch (error) {
      debugPrint('同步后重新排程用药提醒失败: $error');
      if (mounted && _service != null) {
        _service!.status.value = '数据已同步，但用药提醒需要重新检查';
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) =>
      _service?.setActive(state == AppLifecycleState.resumed);
  @override
  Widget build(BuildContext context) {
    ref.listen(todoSyncProvider, (_, next) => _attach(next));
    final service = ref.watch(todoSyncProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _attach(service);
    });
    return widget.child;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _updates?.cancel();
    _service?.setActive(false);
    super.dispose();
  }
}

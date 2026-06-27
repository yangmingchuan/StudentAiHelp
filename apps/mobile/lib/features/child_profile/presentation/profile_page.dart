import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:little_hero/core/theme/app_theme.dart';
import 'package:little_hero/core/widgets/page_heading.dart';
import 'package:little_hero/features/auth/application/auth_controller.dart';
import 'package:little_hero/features/today_tasks/application/home_controller.dart';
import 'package:little_hero/features/today_tasks/domain/home_snapshot.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage>
    with WidgetsBindingObserver {
  int _tapCount = 0;
  DateTime? _firstTapAt;
  bool _parentAreaVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if ((state == AppLifecycleState.paused ||
            state == AppLifecycleState.inactive) &&
        _parentAreaVisible) {
      setState(() => _parentAreaVisible = false);
    }
  }

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('退出登录？'),
        content: const Text('退出后需要重新输入账号和密码才能继续使用。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('退出登录'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(authControllerProvider.notifier).signOut();
    }
  }

  void _handleHeaderTap() {
    final now = DateTime.now();
    final first = _firstTapAt;
    if (first == null || now.difference(first) > const Duration(seconds: 3)) {
      _firstTapAt = now;
      _tapCount = 1;
      return;
    }

    _tapCount += 1;
    if (_tapCount >= 5) {
      setState(() {
        _parentAreaVisible = true;
        _tapCount = 0;
        _firstTapAt = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final session = authState.asData?.value;
    final username = session?.username ?? '账号加载中';
    final homeState = ref.watch(homeControllerProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _handleHeaderTap,
          child: const PageHeading(title: '我的成长', subtitle: '看看今天收获了多少星星'),
        ),
        const SizedBox(height: 28),
        homeState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Card(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Text(error.toString()),
            ),
          ),
          data: (snapshot) => _GrowthCard(snapshot: snapshot),
        ),
        const SizedBox(height: 18),
        Card(
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 8,
            ),
            leading: const Icon(Icons.checklist_rtl_rounded),
            title: const Text('Todo 管理'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push('/todos'),
          ),
        ),
        if (_parentAreaVisible) ...[
          const SizedBox(height: 18),
          homeState.maybeWhen(
            data: (snapshot) => _ParentAreaCard(
              username: username,
              snapshot: snapshot,
              isSigningOut: authState.isLoading,
              canSignOut: session != null,
              onExit: () => setState(() => _parentAreaVisible = false),
              onSignOut: session == null
                  ? null
                  : () => _confirmSignOut(context, ref),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ],
    );
  }
}

class _GrowthCard extends StatelessWidget {
  const _GrowthCard({required this.snapshot});

  final HomeSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 36,
                  backgroundColor: AppColors.green,
                  child: Icon(Icons.face_rounded, color: Colors.white, size: 42),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        snapshot.child.nickname,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '今天还有 ${snapshot.assets.heartsRemaining} 颗小心心',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                _MetricTile(
                  icon: Icons.star_rounded,
                  label: '可用星星',
                  value: snapshot.assets.availableStars.toString(),
                  color: AppColors.orange,
                ),
                const SizedBox(width: 10),
                _MetricTile(
                  icon: Icons.timeline_rounded,
                  label: '累计星星',
                  value: snapshot.assets.lifetimeStars.toString(),
                  color: AppColors.blue,
                ),
                const SizedBox(width: 10),
                _MetricTile(
                  icon: Icons.workspace_premium_rounded,
                  label: '勋章',
                  value:
                      '${snapshot.badges.earnedCount}/${snapshot.badges.totalCount}',
                  color: AppColors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ParentAreaCard extends ConsumerWidget {
  const _ParentAreaCard({
    required this.username,
    required this.snapshot,
    required this.isSigningOut,
    required this.canSignOut,
    required this.onExit,
    required this.onSignOut,
  });

  final String username;
  final HomeSnapshot snapshot;
  final bool isSigningOut;
  final bool canSignOut;
  final VoidCallback onExit;
  final VoidCallback? onSignOut;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.admin_panel_settings_rounded),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '家长区',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  tooltip: '退出家长区',
                  onPressed: onExit,
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '家长账号 $username',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 16),
            _TaskManagementList(tasks: snapshot.tasks),
            const Divider(height: 28),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.logout_rounded),
              title: const Text('退出登录'),
              trailing: const Icon(Icons.chevron_right_rounded),
              enabled: canSignOut && !isSigningOut,
              onTap: onSignOut,
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskManagementList extends ConsumerWidget {
  const _TaskManagementList({required this.tasks});

  final List<TaskSummary> tasks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(homeControllerProvider.notifier);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '任务管理',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            IconButton.filledTonal(
              tooltip: '新增任务',
              onPressed: () => _showTaskDialog(context, ref),
              icon: const Icon(Icons.add_rounded),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          itemCount: tasks.length,
          onReorderItem: controller.moveTask,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return ListTile(
              key: ValueKey(task.id),
              contentPadding: EdgeInsets.zero,
              leading: ReorderableDragStartListener(
                index: index,
                child: const Icon(Icons.drag_indicator_rounded),
              ),
              title: Text(task.name),
              trailing: Wrap(
                children: [
                  IconButton(
                    tooltip: '编辑',
                    onPressed: () => _showTaskDialog(context, ref, task: task),
                    icon: const Icon(Icons.edit_rounded),
                  ),
                  IconButton(
                    tooltip: '删除',
                    onPressed: () => _confirmDelete(context, ref, task),
                    icon: const Icon(Icons.delete_outline_rounded),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> _showTaskDialog(
    BuildContext context,
    WidgetRef ref, {
    TaskSummary? task,
  }) async {
    final controller = TextEditingController(text: task?.name ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(task == null ? '新增任务' : '编辑任务'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 14,
          decoration: const InputDecoration(labelText: '任务名称'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('保存'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (result == null) return;

    try {
      if (task == null) {
        await ref.read(homeControllerProvider.notifier).addTask(result);
      } else {
        await ref
            .read(homeControllerProvider.notifier)
            .updateTask(task.id, result);
      }
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    TaskSummary task,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除任务？'),
        content: Text('删除后，${task.name} 的历史打卡记录仍会保留。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref.read(homeControllerProvider.notifier).deleteTask(task.id);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }
}

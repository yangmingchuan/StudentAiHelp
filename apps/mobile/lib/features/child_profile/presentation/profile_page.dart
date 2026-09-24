import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:little_hero/core/theme/app_theme.dart';
import 'package:little_hero/features/auth/application/auth_controller.dart';
import 'package:little_hero/features/child_profile/data/growth_history_repository.dart';
import 'package:little_hero/features/child_profile/domain/growth_history.dart';
import 'package:little_hero/features/mama_tools/presentation/cycle_widgets.dart';
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
  bool _isSigningOut = false;

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
      if (!context.mounted) return;
      setState(() => _isSigningOut = true);
      try {
        await ref.read(authControllerProvider.notifier).signOut();
      } catch (error) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      } finally {
        if (mounted) {
          setState(() => _isSigningOut = false);
        }
      }
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
    final historyState = ref.watch(growthHistoryProvider);

    return CycleScene(
      child: ListView(
        padding: cyclePagePadding(context),
        children: [
          homeState.when(
            loading: () => const _ProfileLoadingHero(),
            error: (error, _) => _ProfileErrorCard(message: error.toString()),
            data: (snapshot) => GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _handleHeaderTap,
              child: _ProfileHero(snapshot: snapshot),
            ),
          ),
          const SizedBox(height: 12),
          historyState.when(
            loading: () => const _HistoryLoadingCard(),
            error: (error, _) => _ProfileErrorCard(message: error.toString()),
            data: (history) => _HistoryPreview(
              history: history,
              onOpenHistory: () => context.push('/profile/history'),
            ),
          ),
          const SizedBox(height: 12),
          _ProfileActionCard(
            icon: Icons.checklist_rtl_rounded,
            title: 'Todo 管理',
            subtitle: '添加、排序和调整每天的任务',
            onTap: () => context.push('/todos'),
          ),
          const SizedBox(height: 12),
          _ProfileActionCard(
            icon: Icons.account_circle_rounded,
            title: '当前账号 $username',
            subtitle: '点按即可退出登录',
            trailing: _isSigningOut
                ? const SizedBox.square(
                    dimension: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.4),
                  )
                : const Icon(Icons.logout_rounded),
            enabled: session != null && !_isSigningOut,
            onTap: session == null || _isSigningOut
                ? null
                : () => _confirmSignOut(context, ref),
          ),
          if (_parentAreaVisible) ...[
            const SizedBox(height: 12),
            homeState.maybeWhen(
              data: (snapshot) => _ParentAreaCard(
                username: username,
                snapshot: snapshot,
                isSigningOut: _isSigningOut,
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
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.snapshot});

  final HomeSnapshot snapshot;

  @override
  Widget build(BuildContext context) => CycleCard(
    padding: const EdgeInsets.fromLTRB(18, 14, 10, 12),
    child: Row(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: AppColors.green.withValues(alpha: 0.18),
          child: const Icon(
            Icons.face_rounded,
            size: 40,
            color: AppColors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                snapshot.child.nickname,
                style: const TextStyle(fontSize: 23),
              ),
              const SizedBox(height: 4),
              const Text(
                '每一次完成，都会变成你的成长足迹',
                style: TextStyle(
                  color: Color(0xFF786B72),
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '累计 ${snapshot.assets.lifetimeStars} 颗星星 · ${snapshot.badges.earnedCount} 枚勋章',
                style: const TextStyle(
                  color: AppColors.green,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        Image.asset(
          DateTime.now().hour >= 7 && DateTime.now().hour < 17
              ? 'assets/mascots/day_explorer_cat.png'
              : 'assets/mascots/night_astronaut_cat.png',
          width: 72,
          height: 82,
        ),
      ],
    ),
  );
}

class _ProfileLoadingHero extends StatelessWidget {
  const _ProfileLoadingHero();

  @override
  Widget build(BuildContext context) => const CycleCard(
    child: SizedBox(
      height: 110,
      child: Center(child: CircularProgressIndicator()),
    ),
  );
}

class _ProfileErrorCard extends StatelessWidget {
  const _ProfileErrorCard({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => CycleCard(
    child: Text(message, style: const TextStyle(fontWeight: FontWeight.w400)),
  );
}

class _HistoryPreview extends StatelessWidget {
  const _HistoryPreview({required this.history, required this.onOpenHistory});

  final GrowthHistorySnapshot history;
  final VoidCallback onOpenHistory;

  @override
  Widget build(BuildContext context) {
    final today = history.days.last;
    return CycleCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.insights_rounded, color: AppColors.orange),
              const SizedBox(width: 8),
              const Expanded(
                child: Text('成长进度', style: TextStyle(fontSize: 19)),
              ),
              TextButton(onPressed: onOpenHistory, child: const Text('历史详情')),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _ProgressRing(
                progress: today.progress,
                color: AppColors.green,
                size: 78,
                center: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${today.doneCount}/${today.totalCount}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Text('今日', style: TextStyle(fontSize: 11)),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Row(
                  children: [
                    _HistoryMetric(
                      value: '${history.currentStreak}',
                      label: '连续完成',
                    ),
                    const SizedBox(width: 10),
                    _HistoryMetric(
                      value: '${history.bestStreak}',
                      label: '最佳连续',
                    ),
                    const SizedBox(width: 10),
                    _HistoryMetric(
                      value: '${history.totalTasks}',
                      label: '每日任务',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('最近 14 天', style: TextStyle(fontSize: 14)),
          const SizedBox(height: 8),
          _HistoryGrid(days: history.days.skip(14).toList()),
        ],
      ),
    );
  }
}

class _HistoryMetric extends StatelessWidget {
  const _HistoryMetric({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 19, color: cycleRose)),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11, color: Color(0xFF786B72)),
        ),
      ],
    ),
  );
}

class _ProgressRing extends StatelessWidget {
  const _ProgressRing({
    required this.progress,
    required this.color,
    required this.size,
    required this.center,
  });

  final double progress;
  final Color color;
  final double size;
  final Widget center;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: Stack(
      alignment: Alignment.center,
      children: [
        SizedBox.square(
          dimension: size,
          child: CircularProgressIndicator(
            value: progress.clamp(0, 1),
            strokeWidth: size >= 70 ? 8 : 4,
            strokeCap: StrokeCap.round,
            color: color,
            backgroundColor: color.withValues(alpha: 0.17),
          ),
        ),
        center,
      ],
    ),
  );
}

class _HistoryGrid extends StatelessWidget {
  const _HistoryGrid({required this.days, this.onSelect, this.selectedDate});

  final List<GrowthHistoryDay> days;
  final ValueChanged<GrowthHistoryDay>? onSelect;
  final DateTime? selectedDate;

  @override
  Widget build(BuildContext context) => GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: days.length,
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 7,
      mainAxisSpacing: 7,
      crossAxisSpacing: 7,
      childAspectRatio: 0.86,
    ),
    itemBuilder: (context, index) {
      final day = days[index];
      final selected =
          selectedDate != null &&
          growthDateKey(day.date) == growthDateKey(selectedDate!);
      return Semantics(
        button: onSelect != null,
        label: '${_shortDate(day.date)}，完成 ${day.doneCount}/${day.totalCount}',
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onSelect == null ? null : () => onSelect!(day),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.orange.withValues(alpha: 0.15)
                  : Colors.white.withValues(alpha: 0.48),
              borderRadius: BorderRadius.circular(12),
              border: selected
                  ? Border.all(color: AppColors.orange.withValues(alpha: 0.62))
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ProgressRing(
                  progress: day.progress,
                  color: day.isFull ? AppColors.green : AppColors.orange,
                  size: 30,
                  center: Text(
                    '${day.doneCount}',
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
                const SizedBox(height: 3),
                Text('${day.date.day}', style: const TextStyle(fontSize: 11)),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _ProfileActionCard extends StatelessWidget {
  const _ProfileActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
    this.enabled = true,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool enabled;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      enabled: enabled,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: CircleAvatar(
        backgroundColor: AppColors.blue.withValues(alpha: 0.14),
        child: Icon(icon, color: AppColors.blue),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w400)),
      subtitle: Text(subtitle),
      trailing: trailing ?? const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    ),
  );
}

class _HistoryLoadingCard extends StatelessWidget {
  const _HistoryLoadingCard();

  @override
  Widget build(BuildContext context) => const CycleCard(
    child: SizedBox(
      height: 180,
      child: Center(child: CircularProgressIndicator()),
    ),
  );
}

class GrowthHistoryPage extends ConsumerStatefulWidget {
  const GrowthHistoryPage({super.key});

  @override
  ConsumerState<GrowthHistoryPage> createState() => _GrowthHistoryPageState();
}

class _GrowthHistoryPageState extends ConsumerState<GrowthHistoryPage> {
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(growthHistoryProvider);
    return CycleScene(
      title: '历史打卡',
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (history) {
          final selected =
              history.dayFor(_selectedDate ?? DateTime.now()) ??
              history.days.last;
          return ListView(
            padding: cyclePagePadding(context),
            children: [
              CycleCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _ProgressRing(
                      progress: selected.progress,
                      color: selected.isFull
                          ? AppColors.green
                          : AppColors.orange,
                      size: 88,
                      center: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${selected.doneCount}/${selected.totalCount}',
                            style: const TextStyle(fontSize: 18),
                          ),
                          const Text('已完成', style: TextStyle(fontSize: 11)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _longDate(selected.date),
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            selected.hasActivity
                                ? '完成 ${selected.doneCount} 项${selected.skippedCount == 0 ? '' : ' · 跳过 ${selected.skippedCount} 项'}'
                                : '这一天还没有打卡记录',
                            style: const TextStyle(
                              color: Color(0xFF786B72),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '当前连续 ${history.currentStreak} 天 · 最佳 ${history.bestStreak} 天',
                            style: const TextStyle(
                              color: cycleRose,
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              CycleCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('28 天打卡表', style: TextStyle(fontSize: 19)),
                    const SizedBox(height: 4),
                    const Text(
                      '点选任意一天，查看当天每项任务的完成情况',
                      style: TextStyle(
                        color: Color(0xFF786B72),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _HistoryGrid(
                      days: history.days,
                      selectedDate: selected.date,
                      onSelect: (day) =>
                          setState(() => _selectedDate = day.date),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _HistoryTaskTable(day: selected),
              const SizedBox(height: 12),
              _RecentDayList(
                days: history.days.reversed.take(7).toList(),
                selectedDate: selected.date,
                onSelect: (day) => setState(() => _selectedDate = day.date),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HistoryTaskTable extends StatelessWidget {
  const _HistoryTaskTable({required this.day});
  final GrowthHistoryDay day;

  @override
  Widget build(BuildContext context) => CycleCard(
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('当天任务', style: TextStyle(fontSize: 19)),
        const SizedBox(height: 8),
        for (final task in day.tasks)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: _taskStatusColor(
                task.status,
              ).withValues(alpha: 0.14),
              child: Icon(
                _taskIcon(task.iconName),
                color: _taskStatusColor(task.status),
              ),
            ),
            title: Text(task.name),
            trailing: _TaskStatusChip(status: task.status),
          ),
      ],
    ),
  );
}

class _TaskStatusChip extends StatelessWidget {
  const _TaskStatusChip({required this.status});
  final TaskStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, icon) = switch (status) {
      TaskStatus.done => ('完成', Icons.check_rounded),
      TaskStatus.skipped => ('跳过', Icons.remove_rounded),
      TaskStatus.none => ('未记录', Icons.circle_outlined),
    };
    final color = _taskStatusColor(status);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: color, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _RecentDayList extends StatelessWidget {
  const _RecentDayList({
    required this.days,
    required this.selectedDate,
    required this.onSelect,
  });
  final List<GrowthHistoryDay> days;
  final DateTime selectedDate;
  final ValueChanged<GrowthHistoryDay> onSelect;

  @override
  Widget build(BuildContext context) => CycleCard(
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('最近一周', style: TextStyle(fontSize: 19)),
        const SizedBox(height: 6),
        for (final day in days)
          ListTile(
            contentPadding: EdgeInsets.zero,
            onTap: () => onSelect(day),
            leading: _ProgressRing(
              progress: day.progress,
              color: day.isFull ? AppColors.green : AppColors.orange,
              size: 42,
              center: Text(
                '${day.doneCount}',
                style: const TextStyle(fontSize: 11),
              ),
            ),
            title: Text(_longDate(day.date)),
            subtitle: Text(
              day.hasActivity
                  ? '完成 ${day.doneCount}/${day.totalCount}'
                  : '没有打卡记录',
            ),
            trailing: growthDateKey(day.date) == growthDateKey(selectedDate)
                ? const Icon(Icons.check_circle_rounded, color: AppColors.green)
                : const Icon(Icons.chevron_right_rounded),
          ),
      ],
    ),
  );
}

Color _taskStatusColor(TaskStatus status) => switch (status) {
  TaskStatus.done => AppColors.green,
  TaskStatus.skipped => AppColors.orange,
  TaskStatus.none => const Color(0xFF9D9692),
};

IconData _taskIcon(String name) => switch (name) {
  'clean_hands_rounded' => Icons.clean_hands_rounded,
  'bed_rounded' => Icons.bed_rounded,
  'auto_stories_rounded' => Icons.auto_stories_rounded,
  _ => Icons.task_alt_rounded,
};

String _shortDate(DateTime date) => '${date.month}/${date.day}';
String _longDate(DateTime date) => '${date.month}月${date.day}日';

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

import 'package:little_hero/core/widgets/tab_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:little_hero/core/theme/app_theme.dart';
import 'package:little_hero/features/auth/application/auth_controller.dart';
import 'package:little_hero/features/child_profile/data/growth_history_repository.dart';
import 'package:little_hero/features/child_profile/data/growth_rewards_repository.dart';
import 'package:little_hero/features/child_profile/domain/growth_history.dart';
import 'package:little_hero/features/child_profile/domain/growth_rewards.dart';
import 'package:little_hero/features/mama_tools/presentation/cycle_widgets.dart';
import 'package:little_hero/features/today_tasks/application/home_controller.dart';
import 'package:little_hero/features/today_tasks/domain/home_snapshot.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeControllerProvider);
    final historyState = ref.watch(growthHistoryProvider);
    final rewardsState = ref.watch(growthRewardsProvider);

    return CycleScene(
      child: ListView(
        padding: cyclePagePadding(context),
        children: [
          homeState.when(
            loading: () => const _ProfileLoadingHero(),
            error: (error, _) => _ProfileErrorCard(message: error.toString()),
            data: (snapshot) => _ProfileHero(snapshot: snapshot),
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
          homeState.when(
            loading: () => const _HistoryLoadingCard(),
            error: (error, _) => _ProfileErrorCard(message: error.toString()),
            data: (snapshot) => rewardsState.when(
              loading: () => const _HistoryLoadingCard(),
              error: (error, _) => _ProfileErrorCard(message: error.toString()),
              data: (rewards) => _RewardShopCard(
                childId: snapshot.child.id,
                availableStars: snapshot.assets.availableStars,
                rewards: rewards,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _ProfileActionCard(
            icon: Icons.settings_rounded,
            title: '家长设置',
            subtitle: '任务安排、休息日、奖励管理与账号',
            onTap: () => context.push('/profile/parent-settings'),
          ),
        ],
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.snapshot});

  final HomeSnapshot snapshot;

  @override
  Widget build(BuildContext context) => TabHeader(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.green.withValues(alpha: 0.18),
              child: const Icon(
                Icons.face_rounded,
                size: 24,
                color: AppColors.green,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                snapshot.child.nickname,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 23),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          '每一次完成，都是成长',
          style: TextStyle(fontSize: 13, color: Color(0xFF786B72)),
        ),
        const SizedBox(height: 6),
        Text(
          '累计 ${snapshot.assets.lifetimeStars} 颗星星 · ${snapshot.badges.earnedCount} 枚勋章',
          style: const TextStyle(fontSize: 13, color: AppColors.green),
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
                      today.isRestDay
                          ? '休息'
                          : '${today.doneCount}/${today.totalCount}',
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
                      label: '近28天最佳',
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
          const SizedBox(height: 14),
          _WeeklyReviewLine(review: history.weeklyReview),
        ],
      ),
    );
  }
}

class _WeeklyReviewLine extends StatelessWidget {
  const _WeeklyReviewLine({required this.review});
  final GrowthWeeklyReview review;

  @override
  Widget build(BuildContext context) {
    final delta = (review.changeFromPrevious * 100).round();
    final trend = delta > 0
        ? '较前7天提高 $delta 个百分点'
        : delta < 0
        ? '较前7天减少 ${delta.abs()} 个百分点'
        : '与前7天持平';
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            _ProgressRing(
              progress: review.completionRate,
              color: AppColors.green,
              size: 48,
              center: Text(
                '${(review.completionRate * 100).round()}%',
                style: const TextStyle(fontSize: 11),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('成长周回顾 · 近7天', style: TextStyle(fontSize: 15)),
                  const Text(
                    '按当前任务与本机打卡记录统计',
                    style: TextStyle(fontSize: 11, color: Color(0xFF786B72)),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '完成 ${review.doneCount}/${review.totalCount} 项 · $trend${review.restDays == 0 ? '' : ' · ${review.restDays} 天休息'}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF786B72),
                      fontWeight: FontWeight.w400,
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
    padding: EdgeInsets.zero,
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
                  color: day.isFull
                      ? AppColors.green
                      : day.isRestDay
                      ? AppColors.blue
                      : AppColors.orange,
                  size: 30,
                  center: day.isRestDay
                      ? const Icon(Icons.hotel_rounded, size: 13)
                      : Text(
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
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: CircleAvatar(
        backgroundColor: AppColors.blue.withValues(alpha: 0.14),
        child: Icon(icon, color: AppColors.blue),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w400)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
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
                          : selected.isRestDay
                          ? AppColors.blue
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
                            selected.isRestDay
                                ? '这一天是休息日，连续记录会保留'
                                : selected.hasActivity
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
        if (day.isRestDay)
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Text(
              '家长安排了休息日，这一天不计入任务完成率。',
              style: TextStyle(
                color: Color(0xFF786B72),
                fontWeight: FontWeight.w400,
              ),
            ),
          )
        else
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
              color: day.isFull
                  ? AppColors.green
                  : day.isRestDay
                  ? AppColors.blue
                  : AppColors.orange,
              size: 42,
              center: Text(
                '${day.doneCount}',
                style: const TextStyle(fontSize: 11),
              ),
            ),
            title: Text(_longDate(day.date)),
            subtitle: Text(
              day.isRestDay
                  ? '休息日 · 连续记录保留'
                  : day.hasActivity
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

class _RewardShopCard extends ConsumerWidget {
  const _RewardShopCard({
    required this.childId,
    required this.availableStars,
    required this.rewards,
  });

  final int childId;
  final int availableStars;
  final GrowthRewardsSnapshot rewards;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeRewards = rewards.rewards.where((reward) => reward.isActive);
    return CycleCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.redeem_rounded, color: AppColors.orange),
              const SizedBox(width: 8),
              const Expanded(
                child: Text('奖励小铺', style: TextStyle(fontSize: 19)),
              ),
              Text(
                '可用 $availableStars 颗星星',
                style: const TextStyle(
                  color: AppColors.green,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (activeRewards.isEmpty)
            const Text(
              '请家长先添加一个可以兑换的小奖励。',
              style: TextStyle(
                color: Color(0xFF786B72),
                fontWeight: FontWeight.w400,
              ),
            )
          else
            for (final reward in activeRewards)
              _RewardOptionTile(
                reward: reward,
                canRequest:
                    availableStars >= reward.costStars &&
                    !rewards.hasPendingFor(reward.id),
                isPending: rewards.hasPendingFor(reward.id),
                onRequest: () => _request(context, ref, reward),
              ),
          const SizedBox(height: 6),
          const Text(
            '休息日与奖励记录保存在本机，暂不跨设备同步。',
            style: TextStyle(fontSize: 12, color: Color(0xFF786B72)),
          ),
          if (rewards.redemptions.isNotEmpty)
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: Text('兑换记录 · ${rewards.redemptions.length}'),
              children: [
                for (final item in rewards.redemptions)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(item.rewardTitle),
                    subtitle: Text(
                      '${_shortDate(item.requestedAt)} · ${item.costStars} 颗星星',
                    ),
                    trailing: Text(switch (item.status) {
                      RewardRedemptionStatus.pending => '等待家长',
                      RewardRedemptionStatus.approved => '已确认',
                      RewardRedemptionStatus.rejected => '已退回星星',
                    }),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _request(
    BuildContext context,
    WidgetRef ref,
    GrowthReward reward,
  ) async {
    final approved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('申请“${reward.title}”？'),
        content: Text('会先暂存 ${reward.costStars} 颗星星，等待家长确认。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('再想想'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('申请兑换'),
          ),
        ],
      ),
    );
    if (approved != true || !context.mounted) return;
    try {
      await ref
          .read(growthRewardsRepositoryProvider)
          .requestReward(childId: childId, reward: reward);
      ref.invalidate(growthRewardsProvider);
      await ref.read(homeControllerProvider.notifier).refreshLocal();
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('已申请，等家长确认后就可以领取。')));
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }
}

class _RewardOptionTile extends StatelessWidget {
  const _RewardOptionTile({
    required this.reward,
    required this.canRequest,
    required this.isPending,
    required this.onRequest,
  });

  final GrowthReward reward;
  final bool canRequest;
  final bool isPending;
  final VoidCallback onRequest;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: CircleAvatar(
      backgroundColor: AppColors.orange.withValues(alpha: 0.14),
      child: const Icon(Icons.card_giftcard_rounded, color: AppColors.orange),
    ),
    title: Text(reward.title),
    subtitle: Text('${reward.costStars} 颗星星'),
    trailing: FilledButton.tonal(
      onPressed: canRequest ? onRequest : null,
      child: Text(isPending ? '等待确认' : '申请'),
    ),
  );
}

/// A dedicated settings route, not an authentication or parental PIN gate.
class ParentSettingsPage extends ConsumerStatefulWidget {
  const ParentSettingsPage({super.key});
  @override
  ConsumerState<ParentSettingsPage> createState() => _ParentSettingsPageState();
}

class _ParentSettingsPageState extends ConsumerState<ParentSettingsPage> {
  bool _isSigningOut = false;

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

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authControllerProvider).asData?.value;
    final home = ref.watch(homeControllerProvider);
    final rewards = ref.watch(growthRewardsProvider);
    return CycleScene(
      title: '家长设置',
      child: ListView(
        padding: cyclePagePadding(context),
        children: [
          const CycleCard(
            child: ListTile(
              leading: Icon(Icons.admin_panel_settings_rounded),
              title: Text('陪伴孩子，按自己的节奏成长'),
              subtitle: Text('在这里安排任务、管理奖励和账号。'),
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
          home.when(
            loading: () => const _HistoryLoadingCard(),
            error: (error, _) => _ProfileErrorCard(message: error.toString()),
            data: (snapshot) => CycleCard(
              padding: const EdgeInsets.all(16),
              child: _RestDayControl(isRestDay: snapshot.isRestDay),
            ),
          ),
          const SizedBox(height: 12),
          home.when(
            loading: () => const _HistoryLoadingCard(),
            error: (error, _) => _ProfileErrorCard(message: error.toString()),
            data: (snapshot) => CycleCard(
              padding: const EdgeInsets.all(16),
              child: rewards.when(
                loading: () => const LinearProgressIndicator(),
                error: (error, _) => Text(error.toString()),
                data: (value) => _ParentRewardsPanel(
                  childId: snapshot.child.id,
                  rewards: value,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          CycleCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('账号与数据', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text('当前账号 ${session?.username ?? '加载中'}'),
                const SizedBox(height: 8),
                const Text(
                  '休息日与奖励记录保存在本机，暂不跨设备同步。',
                  style: TextStyle(fontSize: 13),
                ),
                const Divider(height: 24),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.logout_rounded),
                  title: const Text('退出登录'),
                  subtitle: const Text('退出前会再次确认'),
                  trailing: _isSigningOut
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.chevron_right_rounded),
                  enabled: session != null && !_isSigningOut,
                  onTap: session == null || _isSigningOut
                      ? null
                      : () => _confirmSignOut(context, ref),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RestDayControl extends ConsumerWidget {
  const _RestDayControl({required this.isRestDay});
  final bool isRestDay;

  @override
  Widget build(BuildContext context, WidgetRef ref) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: CircleAvatar(
      backgroundColor: AppColors.blue.withValues(alpha: 0.14),
      child: const Icon(Icons.hotel_rounded, color: AppColors.blue),
    ),
    title: const Text('今天休息日'),
    subtitle: Text(isRestDay ? '当天任务暂停，连续记录会保留' : '生病或出行时可暂停当天任务'),
    trailing: Switch.adaptive(
      value: isRestDay,
      onChanged: (value) async {
        try {
          await ref
              .read(homeControllerProvider.notifier)
              .setTodayRestDay(value);
          ref.invalidate(growthHistoryProvider);
        } catch (error) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(error.toString())));
        }
      },
    ),
  );
}

class _ParentRewardsPanel extends ConsumerWidget {
  const _ParentRewardsPanel({required this.childId, required this.rewards});
  final int childId;
  final GrowthRewardsSnapshot rewards;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          const Expanded(child: Text('奖励管理', style: TextStyle(fontSize: 18))),
          IconButton.filledTonal(
            tooltip: '新增奖励',
            onPressed: () => _showAddReward(context, ref),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      const SizedBox(height: 6),
      if (rewards.rewards.isEmpty)
        const Text(
          '先添加一个真实奖励，例如“挑选睡前绘本”。',
          style: TextStyle(
            color: Color(0xFF786B72),
            fontWeight: FontWeight.w400,
          ),
        )
      else
        for (final reward in rewards.rewards)
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: Text(reward.title),
            subtitle: Text('${reward.costStars} 颗星星'),
            value: reward.isActive,
            onChanged: (active) => _setActive(context, ref, reward, active),
          ),
      if (rewards.pendingRedemptions.isNotEmpty) ...[
        const SizedBox(height: 8),
        const Text('等待确认', style: TextStyle(fontSize: 15)),
        for (final redemption in rewards.pendingRedemptions)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.hourglass_top_rounded, color: cycleRose),
            title: Text(redemption.rewardTitle),
            subtitle: Text('已暂存 ${redemption.costStars} 颗星星'),
            trailing: Wrap(
              spacing: 2,
              children: [
                IconButton(
                  tooltip: '拒绝兑换',
                  onPressed: () => _resolve(context, ref, redemption, false),
                  icon: const Icon(Icons.close_rounded),
                ),
                IconButton.filledTonal(
                  tooltip: '确认兑换',
                  onPressed: () => _resolve(context, ref, redemption, true),
                  icon: const Icon(Icons.check_rounded),
                ),
              ],
            ),
          ),
      ],
    ],
  );

  Future<void> _showAddReward(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<(String, int)>(
      context: context,
      builder: (context) => const _AddRewardDialog(),
    );
    if (result == null || !context.mounted) return;
    try {
      await ref
          .read(growthRewardsRepositoryProvider)
          .addReward(childId: childId, title: result.$1, costStars: result.$2);
      ref.invalidate(growthRewardsProvider);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  Future<void> _setActive(
    BuildContext context,
    WidgetRef ref,
    GrowthReward reward,
    bool isActive,
  ) async {
    try {
      await ref
          .read(growthRewardsRepositoryProvider)
          .setRewardActive(rewardId: reward.id, isActive: isActive);
      ref.invalidate(growthRewardsProvider);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  Future<void> _resolve(
    BuildContext context,
    WidgetRef ref,
    GrowthRewardRedemption redemption,
    bool approve,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(approve ? '家长确认兑换' : '退回兑换申请'),
        content: Text(
          approve
              ? '确认将“${redemption.rewardTitle}”交给孩子？已暂存的星星不会再次扣除。'
              : '退回“${redemption.rewardTitle}”申请，并返还 ${redemption.costStars} 颗星星？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确认'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await ref
          .read(growthRewardsRepositoryProvider)
          .resolveRedemption(redemptionId: redemption.id, approve: approve);
      ref.invalidate(growthRewardsProvider);
      await ref.read(homeControllerProvider.notifier).refreshLocal();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(approve ? '已确认兑换，请把奖励交给孩子。' : '已拒绝申请，星星已退回。')),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }
}

class _AddRewardDialog extends StatefulWidget {
  const _AddRewardDialog();

  @override
  State<_AddRewardDialog> createState() => _AddRewardDialogState();
}

class _AddRewardDialogState extends State<_AddRewardDialog> {
  final _title = TextEditingController();
  final _stars = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    _stars.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('新增奖励'),
    scrollable: true,
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _title,
          maxLength: 18,
          decoration: const InputDecoration(labelText: '奖励名称'),
        ),
        TextField(
          controller: _stars,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: '需要几颗星星'),
        ),
        if (_error != null)
          Text(
            _error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('取消'),
      ),
      FilledButton(
        onPressed: () {
          final cost = int.tryParse(_stars.text.trim());
          if (_title.text.trim().isEmpty ||
              cost == null ||
              cost < 1 ||
              cost > 999) {
            setState(() => _error = '请填写奖励名称，星星数量需为 1～999 的整数');
            return;
          }
          Navigator.pop(context, (_title.text, cost));
        },
        child: const Text('添加'),
      ),
    ],
  );
}

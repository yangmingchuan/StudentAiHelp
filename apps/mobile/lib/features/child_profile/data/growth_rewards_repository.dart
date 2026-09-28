import 'package:drift/drift.dart';
import 'package:little_hero/core/sync/sync_id.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:little_hero/core/database/local_database.dart';
import 'package:little_hero/features/child_profile/domain/growth_rewards.dart';
import 'package:little_hero/features/today_tasks/application/home_controller.dart';

final growthRewardsRepositoryProvider = Provider<GrowthRewardsRepository>((
  ref,
) {
  return GrowthRewardsRepository(ref.watch(localDatabaseProvider));
});

final growthRewardsProvider = FutureProvider<GrowthRewardsSnapshot>((
  ref,
) async {
  final home = ref.watch(homeControllerProvider).asData?.value;
  if (home == null) {
    return const GrowthRewardsSnapshot(rewards: [], redemptions: []);
  }
  return ref
      .watch(growthRewardsRepositoryProvider)
      .load(childId: home.child.id);
});

class GrowthRewardsRepository {
  const GrowthRewardsRepository(this._db);

  final LocalDatabase _db;

  Future<GrowthRewardsSnapshot> load({required int childId}) async {
    final rewards =
        await (_db.select(_db.localRewards)
              ..where((table) => table.childId.equals(childId))
              ..orderBy([(table) => OrderingTerm.asc(table.sortOrder)]))
            .get();
    final redemptions =
        await (_db.select(_db.localRewardRedemptions)
              ..where((table) => table.childId.equals(childId))
              ..orderBy([(table) => OrderingTerm.desc(table.requestedAt)]))
            .get();
    return GrowthRewardsSnapshot(
      rewards: [
        for (final reward in rewards)
          GrowthReward(
            id: reward.id,
            title: reward.title,
            costStars: reward.costStars,
            isActive: reward.isActive,
          ),
      ],
      redemptions: [
        for (final redemption in redemptions)
          GrowthRewardRedemption(
            id: redemption.id,
            rewardId: redemption.rewardId,
            rewardTitle: redemption.rewardTitle,
            costStars: redemption.costStars,
            status: RewardRedemptionStatus.parse(redemption.status),
            requestedAt: redemption.requestedAt,
          ),
      ],
    );
  }

  Future<void> addReward({
    required int childId,
    required String title,
    required int costStars,
  }) async {
    final cleanTitle = title.trim();
    if (cleanTitle.isEmpty || cleanTitle.length > 18) {
      throw ArgumentError('奖励名称需为 1 到 18 个字符');
    }
    if (costStars <= 0 || costStars > 999) {
      throw ArgumentError('星星价格需在 1 到 999 之间');
    }
    final count =
        await (_db.select(_db.localRewards)
              ..where((table) => table.childId.equals(childId)))
            .get()
            .then((items) => items.length);
    await _db
        .into(_db.localRewards)
        .insert(
          LocalRewardsCompanion.insert(
            id: Value(SyncId.next()),
            childId: childId,
            title: cleanTitle,
            costStars: costStars,
            sortOrder: Value((count + 1) * 10),
          ),
        );
  }

  Future<void> setRewardActive({
    required int rewardId,
    required bool isActive,
  }) =>
      (_db.update(
        _db.localRewards,
      )..where((table) => table.id.equals(rewardId))).write(
        LocalRewardsCompanion(
          isActive: Value(isActive),
          updatedAt: Value(DateTime.now()),
        ),
      );

  Future<void> requestReward({
    required int childId,
    required GrowthReward reward,
  }) async {
    await _db.transaction(() async {
      final stored =
          await (_db.select(_db.localRewards)..where(
                (table) =>
                    table.id.equals(reward.id) & table.childId.equals(childId),
              ))
              .getSingleOrNull();
      if (stored == null || !stored.isActive) throw StateError('这个奖励暂时不能兑换');
      if (stored.costStars != reward.costStars ||
          stored.title != reward.title) {
        throw StateError('奖励已更新，请刷新后重新申请');
      }
      final existing =
          await (_db.select(_db.localRewardRedemptions)..where(
                (table) =>
                    table.childId.equals(childId) &
                    table.rewardId.equals(reward.id) &
                    table.status.equals('pending'),
              ))
              .getSingleOrNull();
      if (existing != null) throw StateError('这个奖励正在等待家长确认');
      final asset = await (_db.select(
        _db.localAssetSnapshots,
      )..where((table) => table.childId.equals(childId))).getSingleOrNull();
      final available = asset?.availableStars ?? 0;
      if (available < reward.costStars) throw StateError('星星还不够，再完成一些任务吧');
      await _db
          .into(_db.localRewardRedemptions)
          .insert(
            LocalRewardRedemptionsCompanion.insert(
              id: Value(SyncId.next()),
              childId: childId,
              rewardId: Value(reward.id),
              rewardTitle: reward.title,
              costStars: reward.costStars,
            ),
          );
      await _writeAvailableStars(childId, available - reward.costStars);
    });
  }

  Future<void> resolveRedemption({
    required int redemptionId,
    required bool approve,
  }) async {
    await _db.transaction(() async {
      final redemption = await (_db.select(
        _db.localRewardRedemptions,
      )..where((table) => table.id.equals(redemptionId))).getSingle();
      if (RewardRedemptionStatus.parse(redemption.status) !=
          RewardRedemptionStatus.pending) {
        throw StateError('这个申请已经处理过了');
      }
      await (_db.update(
        _db.localRewardRedemptions,
      )..where((table) => table.id.equals(redemptionId))).write(
        LocalRewardRedemptionsCompanion(
          status: Value(approve ? 'approved' : 'rejected'),
          resolvedAt: Value(DateTime.now()),
        ),
      );
      if (!approve) {
        final asset =
            await (_db.select(_db.localAssetSnapshots)
                  ..where((table) => table.childId.equals(redemption.childId)))
                .getSingleOrNull();
        await _writeAvailableStars(
          redemption.childId,
          (asset?.availableStars ?? 0) + redemption.costStars,
        );
      }
    });
  }

  Future<void> _writeAvailableStars(int childId, int stars) async {
    final asset = await (_db.select(
      _db.localAssetSnapshots,
    )..where((table) => table.childId.equals(childId))).getSingleOrNull();
    await _db
        .into(_db.localAssetSnapshots)
        .insertOnConflictUpdate(
          LocalAssetSnapshotsCompanion.insert(
            childId: Value(childId),
            availableStars: Value(stars),
            lifetimeStars: Value(asset?.lifetimeStars ?? 0),
            badgeCount: Value(asset?.badgeCount ?? 0),
            heartsRemaining: Value(asset?.heartsRemaining ?? 10),
            heartsLimit: Value(asset?.heartsLimit ?? 10),
            snapshotDate: asset?.snapshotDate ?? _today(),
          ),
        );
  }

  String _today() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }
}

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:little_hero/core/database/local_database.dart';
import 'package:little_hero/features/child_profile/data/growth_history_repository.dart';
import 'package:little_hero/features/child_profile/data/growth_rewards_repository.dart';
import 'package:little_hero/features/child_profile/domain/growth_rewards.dart';
import 'package:little_hero/features/today_tasks/data/home_api.dart';
import 'package:little_hero/features/today_tasks/data/home_repository.dart';
import 'package:little_hero/features/today_tasks/domain/home_snapshot.dart';
import 'package:little_hero/core/sync/operation_id_factory.dart';
import 'package:uuid/uuid.dart';

void main() {
  late LocalDatabase db;

  setUp(() async {
    db = LocalDatabase.forTesting(NativeDatabase.memory());
    await db
        .into(db.localChildren)
        .insert(
          LocalChildrenCompanion.insert(
            id: const Value(1),
            nickname: const Value('小勇士'),
          ),
        );
    await db
        .into(db.localAssetSnapshots)
        .insert(
          LocalAssetSnapshotsCompanion.insert(
            childId: const Value(1),
            availableStars: const Value(12),
            lifetimeStars: const Value(12),
            snapshotDate: _dateKey(DateTime.now()),
          ),
        );
  });

  tearDown(() => db.close());

  HomeRepository home() =>
      HomeRepository(db, _FakeHomeApi(), const OperationIdFactory(Uuid()));

  test(
    'template icon persists through save, rename and local reload',
    () async {
      final snapshot = await home().addTask(
        name: '跳绳',
        iconName: 'task_jump_rope',
      );
      final task = snapshot.tasks.single;
      expect(task.iconName, 'task_jump_rope');
      await home().updateTask(taskId: task.id, name: '跳绳十分钟');
      final reloaded = await home().load(refreshRemote: false);
      expect(reloaded.tasks.single.iconName, 'task_jump_rope');
      final sweep = await home().addTask(name: '扫地');
      expect(sweep.tasks.last.iconName, 'task_sweep');
    },
  );

  test(
    'refresh preserves pending and approved deductions without duplicating them',
    () async {
      final repository = GrowthRewardsRepository(db);
      await repository.addReward(childId: 1, title: '绘本', costStars: 5);
      final reward = (await repository.load(childId: 1)).rewards.single;
      await repository.requestReward(childId: 1, reward: reward);
      await home().load();
      expect(await _availableStars(db), 7);
      final request = (await repository.load(childId: 1)).redemptions.single;
      await repository.resolveRedemption(
        redemptionId: request.id,
        approve: true,
      );
      await home().load();
      await home().load();
      expect(await _availableStars(db), 7);
    },
  );

  test(
    'stale, duplicate, unaffordable and disabled requests cannot spend stars',
    () async {
      final repository = GrowthRewardsRepository(db);
      await repository.addReward(childId: 1, title: '绘本', costStars: 7);
      final reward = (await repository.load(childId: 1)).rewards.single;
      await expectLater(
        repository.requestReward(childId: 2, reward: reward),
        throwsStateError,
      );
      await expectLater(
        repository.requestReward(
          childId: 1,
          reward: GrowthReward(
            id: reward.id,
            title: reward.title,
            costStars: 1,
            isActive: true,
          ),
        ),
        throwsStateError,
      );
      await repository.requestReward(childId: 1, reward: reward);
      await expectLater(
        repository.requestReward(childId: 1, reward: reward),
        throwsStateError,
      );
      await repository.addReward(childId: 1, title: '电影', costStars: 8);
      final other = (await repository.load(childId: 1)).rewards.last;
      await expectLater(
        repository.requestReward(childId: 1, reward: other),
        throwsStateError,
      );
      final request = (await repository.load(childId: 1)).redemptions.single;
      await repository.resolveRedemption(
        redemptionId: request.id,
        approve: false,
      );
      await expectLater(
        repository.resolveRedemption(redemptionId: request.id, approve: false),
        throwsStateError,
      );
      await repository.setRewardActive(rewardId: reward.id, isActive: false);
      await expectLater(
        repository.requestReward(childId: 1, reward: reward),
        throwsStateError,
      );
      expect(await _availableStars(db), 12);
    },
  );

  test(
    'rest day blocks task stars, survives reload and can be resumed',
    () async {
      final repository = home();
      await repository.setTodayRestDay(isRestDay: true);
      expect((await repository.load(refreshRemote: false)).isRestDay, isTrue);
      await expectLater(
        repository.setTaskStatus(taskId: 101, nextStatus: TaskStatus.done),
        throwsStateError,
      );
      expect(await _availableStars(db), 12);
      await repository.setTodayRestDay(isRestDay: false);
      expect((await repository.load(refreshRemote: false)).isRestDay, isFalse);
    },
  );

  test('short history ranges are valid', () async {
    final history = await GrowthHistoryRepository(db).load(days: 1);
    expect(history.days, hasLength(1));
    expect(history.weeklyReview.totalCount, 0);
  });

  test('completed tasks must be undone before setting rest day', () async {
    await db
        .into(db.localHabitRecords)
        .insert(
          LocalHabitRecordsCompanion.insert(
            childId: 1,
            habitId: 101,
            recordDate: _dateKey(DateTime.now()),
            status: const Value('done'),
          ),
        );
    await expectLater(
      home().setTodayRestDay(isRestDay: true),
      throwsStateError,
    );
    expect(await db.select(db.localRestDays).get(), isEmpty);
    expect(await _availableStars(db), 12);
  });

  test('an unfinished today does not break yesterday streak', () async {
    await db
        .into(db.localHabits)
        .insert(
          LocalHabitsCompanion.insert(
            id: const Value(101),
            childId: 1,
            name: '刷牙',
          ),
        );
    await db
        .into(db.localHabitRecords)
        .insert(
          LocalHabitRecordsCompanion.insert(
            childId: 1,
            habitId: 101,
            recordDate: _dateKey(
              _dateOnly(DateTime.now()).subtract(const Duration(days: 1)),
            ),
            status: const Value('done'),
          ),
        );
    expect((await GrowthHistoryRepository(db).load()).currentStreak, 1);
  });

  test(
    'a refund after a remote correction does not mint extra stars',
    () async {
      final repository = GrowthRewardsRepository(db);
      await repository.addReward(childId: 1, title: '绘本', costStars: 12);
      await repository.requestReward(
        childId: 1,
        reward: (await repository.load(childId: 1)).rewards.single,
      );
      final request = (await repository.load(childId: 1)).redemptions.single;
      final correctedHome = HomeRepository(
        db,
        _FakeHomeApi(stars: 10),
        const OperationIdFactory(Uuid()),
      );
      expect((await correctedHome.load()).assets.availableStars, 0);
      await repository.resolveRedemption(
        redemptionId: request.id,
        approve: false,
      );
      expect(await _availableStars(db), 10);
    },
  );

  test('reward request reserves stars and rejection returns them', () async {
    final repository = GrowthRewardsRepository(db);
    await repository.addReward(childId: 1, title: '挑选睡前绘本', costStars: 7);
    final reward = (await repository.load(childId: 1)).rewards.single;

    await repository.requestReward(childId: 1, reward: reward);
    expect(await _availableStars(db), 5);
    var result = await repository.load(childId: 1);
    expect(result.pendingRedemptions, hasLength(1));

    await repository.resolveRedemption(
      redemptionId: result.pendingRedemptions.single.id,
      approve: false,
    );
    expect(await _availableStars(db), 12);
    result = await repository.load(childId: 1);
    expect(result.redemptions.single.status, RewardRedemptionStatus.rejected);
  });

  test(
    'approved reward remains deducted and keeps a redemption record',
    () async {
      final repository = GrowthRewardsRepository(db);
      await repository.addReward(childId: 1, title: '周末选电影', costStars: 5);
      final reward = (await repository.load(childId: 1)).rewards.single;
      await repository.requestReward(childId: 1, reward: reward);
      final request = (await repository.load(
        childId: 1,
      )).pendingRedemptions.single;

      await repository.resolveRedemption(
        redemptionId: request.id,
        approve: true,
      );
      expect(await _availableStars(db), 7);
      final result = await repository.load(childId: 1);
      expect(result.redemptions.single.status, RewardRedemptionStatus.approved);
    },
  );

  test(
    'rest day is excluded from the weekly denominator and streak break',
    () async {
      final today = _dateOnly(DateTime.now());
      final yesterday = today.subtract(const Duration(days: 1));
      await db
          .into(db.localHabits)
          .insert(
            LocalHabitsCompanion.insert(
              id: const Value(101),
              childId: 1,
              name: '刷牙',
            ),
          );
      await db
          .into(db.localHabitRecords)
          .insert(
            LocalHabitRecordsCompanion.insert(
              childId: 1,
              habitId: 101,
              recordDate: _dateKey(yesterday),
              status: const Value('done'),
            ),
          );
      await db
          .into(db.localRestDays)
          .insert(
            LocalRestDaysCompanion.insert(
              childId: 1,
              restDate: _dateKey(today),
            ),
          );

      final history = await GrowthHistoryRepository(db).load();
      expect(history.days.last.isRestDay, isTrue);
      expect(history.currentStreak, 1);
      expect(history.weeklyReview.restDays, 1);
      expect(history.weeklyReview.totalCount, 6);
    },
  );
}

class _FakeHomeApi implements HomeApi {
  _FakeHomeApi({this.stars = 12});
  final int stars;
  @override
  Future<Map<String, dynamic>> bootstrap() async => {
    'child': {'id': 1},
    'assets': {'availableStars': stars, 'lifetimeStars': stars},
    'serverDate': _dateKey(DateTime.now()),
    'todayTasks': <dynamic>[],
  };
  @override
  Future<Map<String, dynamic>> submitTaskStatus({
    required String operationId,
    required int childId,
    required int taskId,
    required String status,
  }) async => {};
  @override
  Future<Map<String, dynamic>> submitTaskManagement({
    required String operationId,
    required String action,
    required Map<String, Object?> payload,
  }) async => {};
}

Future<int> _availableStars(LocalDatabase db) async => (await (db.select(
  db.localAssetSnapshots,
)..where((table) => table.childId.equals(1))).getSingle()).availableStars;

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

String _dateKey(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

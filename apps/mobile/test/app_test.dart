import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:little_hero/app/app.dart';
import 'package:little_hero/core/widgets/tab_header.dart';
import 'package:little_hero/features/auth/application/auth_controller.dart';
import 'package:little_hero/features/auth/domain/auth_session.dart';
import 'package:little_hero/features/child_profile/data/growth_history_repository.dart';
import 'package:little_hero/features/child_profile/data/growth_rewards_repository.dart';
import 'package:little_hero/features/child_profile/domain/growth_history.dart';
import 'package:little_hero/features/child_profile/domain/growth_rewards.dart';
import 'package:little_hero/features/mama_tools/application/cycle_controller.dart';
import 'package:little_hero/features/mama_tools/domain/cycle_models.dart';
import 'package:little_hero/features/medication/application/medication_controller.dart';
import 'package:little_hero/features/medication/domain/medication_models.dart';
import 'package:little_hero/features/medication/presentation/medication_home_page.dart';
import 'package:little_hero/features/today_tasks/application/home_controller.dart';
import 'package:little_hero/features/today_tasks/domain/home_snapshot.dart';

class _SignedInAuthController extends AuthController {
  @override
  Future<AuthSession?> build() async {
    return AuthSession(
      accessToken: 'test-access-token',
      refreshToken: 'test-refresh-token',
      subject: 'test-user',
      username: '13800138000',
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
    );
  }
}

class _TestHomeController extends HomeController {
  var _tasks = const [
    TaskSummary(
      id: 101,
      name: '自己刷牙',
      iconName: 'clean_hands_rounded',
      sortOrder: 10,
      status: TaskStatus.none,
    ),
  ];

  @override
  Future<void> setTaskStatus(int taskId, TaskStatus status) async {
    _tasks = [
      for (final task in _tasks)
        TaskSummary(
          id: task.id,
          name: task.name,
          iconName: task.iconName,
          sortOrder: task.sortOrder,
          status: task.id == taskId ? status : task.status,
        ),
    ];
    state = AsyncData(_snapshot());
  }

  @override
  Future<void> clearTaskStatus(int taskId) =>
      setTaskStatus(taskId, TaskStatus.none);

  @override
  Future<HomeSnapshot> build() async {
    return _snapshot();
  }

  @override
  Future<void> addTask(String name) async {
    _tasks = [
      ..._tasks,
      TaskSummary(
        id: 202,
        name: name.trim(),
        iconName: 'task_alt_rounded',
        sortOrder: 20,
        status: TaskStatus.none,
      ),
    ];
    state = AsyncData(_snapshot());
  }

  HomeSnapshot _snapshot() {
    return HomeSnapshot(
      child: const ChildSummary(
        id: 1,
        nickname: '小勇士',
        avatarIcon: 'face_rounded',
        avatarColor: 'green',
        needsProfileSetup: true,
      ),
      assets: const AssetSummary(
        availableStars: 0,
        lifetimeStars: 0,
        badgeCount: 0,
        heartsRemaining: 10,
        heartsLimit: 10,
      ),
      tasks: _tasks,
      badges: const BadgeSummary(earnedCount: 0, totalCount: 3),
      isRestDay: false,
      isStale: false,
      isSyncing: false,
    );
  }
}

class _TestCycleController extends CycleController {
  @override
  Future<CycleSnapshot> build() async {
    final today = DateTime(2026, 6, 29);
    final selectedDay = CycleDayInfo(
      date: today,
      cycleDay: 2,
      phase: CyclePhase.menstrual,
      tags: const ['月经期'],
      summary: '月经期第2天',
      advice: '多喝温水，注意保暖和休息。',
      diaryText: '',
      hasDiary: false,
    );
    return CycleSnapshot(
      needsSetup: false,
      profile: CycleProfileSummary(
        lastPeriodStartDate: DateTime(2026, 6, 28),
        periodLengthDays: 5,
        cycleLengthDays: 28,
        birthDate: DateTime(1995, 1, 1),
        cloudSyncEnabled: false,
      ),
      today: today,
      visibleMonth: DateTime(2026, 6),
      selectedDate: today,
      calendarDays: [
        CycleCalendarDay(
          date: today,
          isInVisibleMonth: true,
          isToday: true,
          isSelected: true,
          info: selectedDay,
        ),
      ],
      selectedDay: selectedDay,
      dailyAdvice: selectedDay.advice,
    );
  }
}

class _TestMedicationController extends MedicationController {
  @override
  Future<MedicationSnapshot> build() async {
    final takenAt = DateTime(2026, 6, 30, 8, 30);
    return MedicationSnapshot(
      members: const [
        MedicationMember(
          id: 1,
          name: '小勇士',
          relation: '孩子',
          ageNote: '6 岁',
          allergyNote: '青霉素过敏',
          conditionNote: '',
        ),
      ],
      medicines: [
        MedicineItem(
          id: 1,
          name: '退热滴剂',
          specification: '100ml',
          defaultDosage: '按医生说明',
          storageLocation: '客厅药箱',
          expiresOn: DateTime(2026, 7, 20),
          stockNote: '剩半瓶',
          usageNote: '发热备用',
          expiryStatus: MedicineExpiryStatus.expiringSoon,
        ),
      ],
      logs: [
        MedicationLogEntry(
          id: 1,
          memberName: '小勇士',
          medicineName: '退热滴剂',
          takenAt: takenAt,
          dosageText: '5ml',
          reason: '发热',
          note: '饭后',
          nextReminderAt: DateTime(2026, 6, 30, 14, 30),
          voidedAt: null,
          voidReason: '',
          correctedByLogId: null,
        ),
      ],
      upcomingReminders: [
        MedicationReminder(
          id: 1,
          memberName: '小勇士',
          medicineName: '退热滴剂',
          remindAt: DateTime(2026, 6, 30, 14, 30),
          dosageText: '5ml',
          status: MedicationReminderStatus.scheduled,
        ),
      ],
      todayLogCount: 1,
      expiringSoonCount: 1,
      expiredCount: 0,
    );
  }
}

GrowthHistorySnapshot _testHistory() {
  final today = DateTime.now();
  final start = DateTime(today.year, today.month, today.day - 27);
  return GrowthHistorySnapshot(
    childId: 1,
    days: [
      for (var offset = 0; offset < 28; offset += 1)
        GrowthHistoryDay(
          date: start.add(Duration(days: offset)),
          totalCount: 1,
          doneCount: offset == 27 ? 1 : 0,
          skippedCount: 0,
          tasks: const [
            GrowthHistoryTask(
              id: 101,
              name: '自己刷牙',
              iconName: 'clean_hands_rounded',
              status: TaskStatus.none,
            ),
          ],
        ),
    ],
    totalTasks: 1,
    currentStreak: 1,
    bestStreak: 1,
    weeklyReview: const GrowthWeeklyReview(
      doneCount: 1,
      totalCount: 7,
      restDays: 0,
      changeFromPrevious: 0,
    ),
  );
}

const _testRewards = GrowthRewardsSnapshot(rewards: [], redemptions: []);

class _EmptyMedicationController extends MedicationController {
  @override
  Future<MedicationSnapshot> build() async => const MedicationSnapshot(
    members: [],
    medicines: [],
    logs: [],
    upcomingReminders: [],
    todayLogCount: 0,
    expiringSoonCount: 0,
    expiredCount: 0,
  );
}

void main() {
  testWidgets(
    'empty medication sections have one action and fit narrow screens',
    (tester) async {
      tester.view.physicalSize = const Size(320, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            medicationControllerProvider.overrideWith(
              _EmptyMedicationController.new,
            ),
          ],
          child: MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                size: Size(320, 900),
                textScaler: TextScaler.linear(1.3),
              ),
              child: const Scaffold(body: MedicationHomePage()),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('记录用药'), findsOneWidget);
      expect(find.text('还没有用药记录'), findsOneWidget);
      expect(find.text('今日用药'), findsNothing);
      expect(find.text('提醒'), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('药品'));
      await tester.pumpAndSettle();
      expect(find.text('添加药品'), findsOneWidget);
      expect(find.text('先添加常备药'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('成员'));
      await tester.pumpAndSettle();
      expect(find.text('添加成员'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'reward dialog validates input and can cancel without disposed controller errors',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith(_SignedInAuthController.new),
            homeControllerProvider.overrideWith(_TestHomeController.new),
            growthHistoryProvider.overrideWith((ref) async => _testHistory()),
            growthRewardsProvider.overrideWith((ref) async => _testRewards),
          ],
          child: const LittleHeroApp(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('我的'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('家长设置'),
        250,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.ensureVisible(find.text('家长设置'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('家长设置'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byTooltip('新增奖励'),
        250,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.ensureVisible(find.byTooltip('新增奖励'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('新增奖励'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('添加'));
      await tester.pumpAndSettle();
      expect(find.text('请填写奖励名称，星星数量需为 1～999 的整数'), findsOneWidget);
      await tester.tap(find.text('取消'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(AlertDialog), findsNothing);
      await tester.scrollUntilVisible(
        find.text('退出登录'),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.ensureVisible(find.text('退出登录'));
      await tester.pumpAndSettle();
      expect(find.text('退出登录'), findsOneWidget);
      await tester.tap(find.text('退出登录'));
      await tester.pumpAndSettle();
      expect(find.text('退出登录？'), findsOneWidget);
      await tester.tap(find.text('取消'));
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('退出登录'), findsNothing);
      expect(find.text('家长设置'), findsOneWidget);
      expect(find.text('我的'), findsOneWidget);
    },
  );

  testWidgets('starts on tasks and opens mama and medication tabs', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(_SignedInAuthController.new),
          homeControllerProvider.overrideWith(_TestHomeController.new),
          cycleControllerProvider.overrideWith(_TestCycleController.new),
          medicationControllerProvider.overrideWith(
            _TestMedicationController.new,
          ),
          growthHistoryProvider.overrideWith((ref) async => _testHistory()),
          growthRewardsProvider.overrideWith((ref) async => _testRewards),
        ],
        child: const LittleHeroApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('小勇士，今天也能做到！'), findsNothing);
    expect(find.text('今日星星  0 / 1'), findsOneWidget);
    final assetPaths = tester
        .widgetList<Image>(find.byType(Image))
        .map((image) => image.image)
        .whereType<AssetImage>()
        .map((asset) => asset.assetName)
        .toList();
    expect(assetPaths, contains('assets/task_icons/brush.png'));
    final hour = DateTime.now().hour;
    expect(
      assetPaths,
      contains(
        hour >= 7 && hour < 17
            ? 'assets/backgrounds/day_meadow.png'
            : 'assets/backgrounds/night_moon.png',
      ),
    );
    expect(find.byTooltip('完成'), findsOneWidget);
    expect(find.byTooltip('清空'), findsNothing);
    expect(find.byTooltip('跳过'), findsNothing);
    expect(find.text('星星'), findsNothing);
    expect(find.text('勋章'), findsNothing);
    expect(find.text('心心'), findsNothing);
    expect(find.text('任务'), findsOneWidget);
    expect(find.text('经期'), findsOneWidget);
    expect(find.text('用药'), findsOneWidget);
    expect(find.text('我的'), findsOneWidget);

    final headerRect = tester.getRect(find.byKey(TabHeader.frameKey));
    expect(headerRect.height, 120);
    expect(
      tester.widget<TabHeader>(find.byType(TabHeader)).showSurface,
      isFalse,
    );
    final mascotRect = tester.getRect(find.byKey(TabHeader.mascotKey));
    void expectSameHeaderGeometry() {
      expect(tester.getRect(find.byKey(TabHeader.frameKey)), headerRect);
      expect(tester.getRect(find.byKey(TabHeader.mascotKey)), mascotRect);
    }

    // Check resolved text spans, including inherited Material label styles.
    for (final richText in tester.widgetList<RichText>(find.byType(RichText))) {
      void checkWeight(InlineSpan span, FontWeight inherited) {
        final weight = span.style?.fontWeight ?? inherited;
        expect(
          weight.value,
          lessThanOrEqualTo(FontWeight.w400.value),
          reason: 'Homepage text must stay regular: ${span.toPlainText()}',
        );
        if (span is TextSpan) {
          for (final child in span.children ?? <InlineSpan>[]) {
            checkWeight(child, weight);
          }
        }
      }

      checkWeight(richText.text, FontWeight.w400);
    }

    await tester.tap(find.byTooltip('完成'));
    await tester.pump();
    for (var frame = 0; frame < 60; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
      expect(
        tester.takeException(),
        isNull,
        reason: 'Completion animation must not break layout',
      );
      expect(find.byKey(TabHeader.frameKey), findsOneWidget);
    }
    expect(find.byTooltip('取消完成'), findsOneWidget);
    await tester.tap(find.byTooltip('取消完成'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('完成'), findsOneWidget);

    await tester.tap(find.text('经期'));
    await tester.pumpAndSettle();
    expect(find.text('经期手记'), findsOneWidget);
    expect(
      tester.widget<TabHeader>(find.byType(TabHeader)).showSurface,
      isFalse,
    );
    expectSameHeaderGeometry();
    expect(find.text('记录今天'), findsOneWidget);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('记录回顾'), findsOneWidget);

    await tester.tap(find.text('用药'));
    await tester.pumpAndSettle();
    expect(find.text('家庭药箱'), findsOneWidget);
    expectSameHeaderGeometry();
    expect(find.text('今日 1 条记录 · 1 种药品'), findsOneWidget);
    expect(find.text('今日用药'), findsNothing);
    expect(find.text('记录用药'), findsOneWidget);
    await tester.drag(find.byType(ListView).last, const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('用药记录'), findsOneWidget);
    expect(find.text('剂量：5ml'), findsOneWidget);
    await tester.tap(find.text('我的'));
    await tester.pumpAndSettle();
    expect(find.text('成长进度'), findsOneWidget);
    expectSameHeaderGeometry();
    expect(find.text('小勇士'), findsWidgets);
    expect(find.text('连续完成'), findsOneWidget);
    await tester.tap(find.text('历史详情'));
    await tester.pumpAndSettle();
    expect(find.text('历史打卡'), findsOneWidget);
    expect(find.text('28 天打卡表'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('退出登录'), findsNothing);
    expect(find.text('Todo 管理'), findsNothing);
    await tester.scrollUntilVisible(
      find.text('家长设置'),
      280,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.ensureVisible(find.text('家长设置'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('家长设置'));
    await tester.pumpAndSettle();
    expect(find.text('我的'), findsNothing);
    await tester.scrollUntilVisible(
      find.text('Todo 管理'),
      280,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.drag(find.byType(ListView).last, const Offset(0, -180));
    await tester.pumpAndSettle();
    expect(find.text('Todo 管理'), findsOneWidget);

    await tester.tap(find.text('Todo 管理'));
    await tester.pumpAndSettle();
    expect(find.text('自己刷牙'), findsOneWidget);
    expect(find.text('任务'), findsNothing);
    expect(find.text('经期'), findsNothing);
    expect(find.text('用药'), findsNothing);
    expect(find.text('我的'), findsNothing);

    await tester.tap(find.byTooltip('新增 Todo'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '喝牛奶');
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();
    expect(find.text('喝牛奶'), findsOneWidget);
  });
}

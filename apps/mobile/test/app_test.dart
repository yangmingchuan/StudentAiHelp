import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:little_hero/app/app.dart';
import 'package:little_hero/features/auth/application/auth_controller.dart';
import 'package:little_hero/features/auth/domain/auth_session.dart';
import 'package:little_hero/features/mama_tools/application/cycle_controller.dart';
import 'package:little_hero/features/mama_tools/domain/cycle_models.dart';
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
      fertilityProbability: 0,
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
      healthScore: 94,
      dailyAdvice: selectedDay.advice,
    );
  }
}

void main() {
  testWidgets('starts on tasks and opens mama and learning tabs', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(_SignedInAuthController.new),
          homeControllerProvider.overrideWith(_TestHomeController.new),
          cycleControllerProvider.overrideWith(_TestCycleController.new),
        ],
        child: const LittleHeroApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('小勇士，今天也要加油'), findsOneWidget);
    expect(find.byTooltip('完成'), findsOneWidget);
    expect(find.byTooltip('清空'), findsNothing);
    expect(find.byTooltip('跳过'), findsNothing);
    expect(find.text('星星'), findsNothing);
    expect(find.text('勋章'), findsNothing);
    expect(find.text('心心'), findsNothing);
    expect(find.text('任务'), findsOneWidget);
    expect(find.text('妈妈'), findsOneWidget);
    expect(find.text('学习'), findsOneWidget);
    expect(find.text('我的'), findsOneWidget);

    await tester.tap(find.text('妈妈'));
    await tester.pumpAndSettle();
    expect(find.text('月经期'), findsWidgets);
    expect(find.text('2026年6月29日 详细说明'), findsOneWidget);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('经期健康分析'), findsOneWidget);

    await tester.tap(find.text('学习'));
    await tester.pumpAndSettle();
    expect(find.text('数学小岛'), findsOneWidget);
    expect(find.text('英语森林'), findsOneWidget);
    expect(find.text('内容准备中'), findsNWidgets(2));

    await tester.tap(find.text('我的'));
    await tester.pumpAndSettle();
    expect(find.text('我的成长'), findsOneWidget);
    expect(find.text('小勇士'), findsWidgets);
    expect(find.text('可用星星'), findsOneWidget);
    expect(find.text('Todo 管理'), findsOneWidget);

    await tester.tap(find.text('Todo 管理'));
    await tester.pumpAndSettle();
    expect(find.text('自己刷牙'), findsOneWidget);
    expect(find.text('任务'), findsNothing);
    expect(find.text('妈妈'), findsNothing);
    expect(find.text('学习'), findsNothing);
    expect(find.text('我的'), findsNothing);

    await tester.tap(find.byTooltip('新增 Todo'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '喝牛奶');
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();
    expect(find.text('喝牛奶'), findsOneWidget);
  });
}

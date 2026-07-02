import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:little_hero/app/app.dart';
import 'package:little_hero/features/auth/application/auth_controller.dart';
import 'package:little_hero/features/auth/domain/auth_session.dart';
import 'package:little_hero/features/mama_tools/application/cycle_controller.dart';
import 'package:little_hero/features/mama_tools/domain/cycle_models.dart';
import 'package:little_hero/features/medication/application/medication_controller.dart';
import 'package:little_hero/features/medication/domain/medication_models.dart';
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
        ),
      ],
      upcomingReminders: [
        MedicationReminder(
          memberName: '小勇士',
          medicineName: '退热滴剂',
          remindAt: DateTime(2026, 6, 30, 14, 30),
          dosageText: '5ml',
        ),
      ],
      todayLogCount: 1,
      expiringSoonCount: 1,
      expiredCount: 0,
    );
  }
}

void main() {
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
    expect(find.text('用药'), findsOneWidget);
    expect(find.text('我的'), findsOneWidget);

    await tester.tap(find.text('妈妈'));
    await tester.pumpAndSettle();
    expect(find.text('月经期'), findsWidgets);
    expect(find.text('2026年6月29日 详细说明'), findsOneWidget);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('经期健康分析'), findsOneWidget);

    await tester.tap(find.text('用药'));
    await tester.pumpAndSettle();
    expect(find.text('家庭药箱'), findsOneWidget);
    expect(find.text('家庭药品'), findsOneWidget);
    expect(find.text('退热滴剂'), findsOneWidget);
    await tester.tap(find.text('记录'));
    await tester.pumpAndSettle();
    expect(find.text('用药记录'), findsOneWidget);
    expect(find.text('剂量：5ml'), findsOneWidget);

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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:little_hero/app/app.dart';
import 'package:little_hero/features/auth/application/auth_controller.dart';
import 'package:little_hero/features/auth/domain/auth_session.dart';
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

void main() {
  testWidgets('starts on tasks and opens learning placeholders', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(_SignedInAuthController.new),
          homeControllerProvider.overrideWith(_TestHomeController.new),
        ],
        child: const LittleHeroApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('小勇士，今天也要加油'), findsOneWidget);
    expect(find.byTooltip('完成'), findsOneWidget);
    expect(find.byTooltip('清空'), findsOneWidget);
    expect(find.byTooltip('跳过'), findsNothing);
    expect(find.text('任务'), findsOneWidget);
    expect(find.text('数学'), findsOneWidget);
    expect(find.text('英语'), findsOneWidget);
    expect(find.text('我的'), findsOneWidget);

    await tester.tap(find.text('数学'));
    await tester.pumpAndSettle();
    expect(find.text('关卡正在准备中'), findsOneWidget);

    await tester.tap(find.text('英语'));
    await tester.pumpAndSettle();
    expect(find.text('内容正在准备中'), findsOneWidget);

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
    expect(find.text('数学'), findsNothing);
    expect(find.text('英语'), findsNothing);
    expect(find.text('我的'), findsNothing);

    await tester.tap(find.byTooltip('新增 Todo'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '喝牛奶');
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();
    expect(find.text('喝牛奶'), findsOneWidget);
  });
}

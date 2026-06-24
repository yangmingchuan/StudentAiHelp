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
  @override
  Future<HomeSnapshot> build() async {
    return const HomeSnapshot(
      child: ChildSummary(
        id: 1,
        nickname: '小勇士',
        avatarIcon: 'face_rounded',
        avatarColor: 'green',
        needsProfileSetup: true,
      ),
      assets: AssetSummary(
        availableStars: 0,
        lifetimeStars: 0,
        badgeCount: 0,
        heartsRemaining: 10,
        heartsLimit: 10,
      ),
      tasks: [
        TaskSummary(
          id: 101,
          name: '自己刷牙',
          iconName: 'clean_hands_rounded',
          sortOrder: 10,
          status: TaskStatus.none,
        ),
      ],
      badges: BadgeSummary(earnedCount: 0, totalCount: 3),
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
  });
}

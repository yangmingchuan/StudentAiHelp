import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:little_hero/app/app.dart';
import 'package:little_hero/features/auth/application/auth_controller.dart';
import 'package:little_hero/features/auth/domain/auth_session.dart';

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

void main() {
  testWidgets('starts on tasks and opens learning placeholders', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(_SignedInAuthController.new),
        ],
        child: const LittleHeroApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('今天也要加油'), findsOneWidget);
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
    expect(find.text('13800138000'), findsOneWidget);
    expect(find.text('已登录'), findsOneWidget);
    expect(find.text('退出登录'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:little_hero/features/auth/application/auth_controller.dart';
import 'package:little_hero/features/auth/domain/auth_exception.dart';
import 'package:little_hero/features/auth/domain/auth_session.dart';
import 'package:little_hero/features/parent_access/data/parent_pin_store.dart';
import 'package:little_hero/features/parent_access/presentation/parent_gate.dart';
import 'support/fake_parent_pin_store.dart';

class _Auth extends AuthController {
  @override
  Future<AuthSession?> build() async => AuthSession(
    accessToken: 'a',
    refreshToken: 'b',
    subject: 'parent',
    username: '13800138000',
    expiresAt: DateTime.now().add(const Duration(hours: 1)),
  );
  @override
  Future<void> reauthenticate(String password) async {
    if (password != 'account-secret') {
      throw const AuthException('INVALID_USERNAME_OR_PASSWORD', '账号或密码不正确。');
    }
  }
}

void main() {
  testWidgets('PIN setup fits a small screen with enlarged text and keyboard', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          parentPinStoreProvider.overrideWithValue(FakeParentPinStore()),
          authControllerProvider.overrideWith(_Auth.new),
        ],
        child: MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(1.5),
              viewInsets: const EdgeInsets.only(bottom: 260),
            ),
            child: child!,
          ),
          home: ParentPinPage(onUnlocked: () {}),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('保存并进入'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('first entry requires four digits and matching confirmation', (
    tester,
  ) async {
    final store = FakeParentPinStore();
    var unlocked = false;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          parentPinStoreProvider.overrideWithValue(store),
          authControllerProvider.overrideWith(_Auth.new),
        ],
        child: MaterialApp(
          home: ParentPinPage(onUnlocked: () => unlocked = true),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('设置家长密码'), findsOneWidget);
    await tester.enterText(find.byKey(const ValueKey('parent-pin')), '0123');
    await tester.enterText(
      find.byKey(const ValueKey('parent-pin-confirm')),
      '0124',
    );
    await tester.tap(find.text('保存并进入'));
    await tester.pumpAndSettle();
    expect(unlocked, isFalse);
    expect(store.pin, isNull);
    expect(find.text('两次输入的密码不一致，请重新确认。'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('parent-pin-confirm')),
      '0123',
    );
    await tester.tap(find.text('保存并进入'));
    await tester.pumpAndSettle();
    expect(unlocked, isTrue);
    expect(store.pin, '0123');
  });

  testWidgets(
    'recovery requires account verification; wrong password preserves old PIN',
    (tester) async {
      final store = FakeParentPinStore(pin: '0123');
      var unlocked = false;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            parentPinStoreProvider.overrideWithValue(store),
            authControllerProvider.overrideWith(_Auth.new),
          ],
          child: MaterialApp(
            home: ParentPinPage(onUnlocked: () => unlocked = true),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('忘记密码？'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('parent-account-password')),
        'wrong',
      );
      await tester.tap(find.text('验证并重设'));
      await tester.pumpAndSettle();
      expect(find.text('账号或密码不正确。'), findsOneWidget);
      expect(store.pin, '0123');
      expect(unlocked, isFalse);
      await tester.enterText(
        find.byKey(const ValueKey('parent-account-password')),
        'account-secret',
      );
      await tester.tap(find.text('验证并重设'));
      await tester.pumpAndSettle();
      expect(find.text('设置新密码'), findsOneWidget);
      expect(store.pin, '0123');
      await tester.enterText(find.byKey(const ValueKey('parent-pin')), '5678');
      await tester.enterText(
        find.byKey(const ValueKey('parent-pin-confirm')),
        '5678',
      );
      await tester.tap(find.text('保存并进入'));
      await tester.pumpAndSettle();
      expect(store.pin, '5678');
      expect(unlocked, isTrue);
    },
  );
}

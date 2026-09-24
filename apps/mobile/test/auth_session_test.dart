import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:little_hero/core/config/app_environment.dart';
import 'package:little_hero/core/security/secure_session_store.dart';
import 'package:little_hero/features/auth/application/auth_controller.dart';
import 'package:little_hero/features/auth/data/auth_api.dart';
import 'package:little_hero/features/auth/domain/auth_exception.dart';
import 'package:little_hero/features/auth/domain/auth_session.dart';
import '../tool/validate_release_config.dart';

AuthSession session({bool expired = false, String token = 'test-access'}) =>
    AuthSession(
      accessToken: token,
      refreshToken: 'test-refresh-$token',
      subject: 'test-subject',
      username: 'test-user',
      expiresAt: DateTime.now().add(Duration(hours: expired ? -1 : 2)),
    );

class FakeAuthApi extends AuthApi {
  FakeAuthApi() : super(Dio(), Dio());
  int refreshCount = 0;
  Object? error;
  Completer<AuthSession>? pending;
  @override
  Future<AuthSession> signIn({
    required String username,
    required String password,
    required String deviceId,
  }) async => session();
  @override
  Future<AuthSession> refresh({
    required String refreshToken,
    required String deviceId,
    required String username,
  }) async {
    refreshCount++;
    if (error != null) throw error!;
    return pending?.future ?? session(token: 'rotated');
  }

  @override
  Future<void> signOut({
    required String accessToken,
    required String deviceId,
  }) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SecureSessionStore store;
  late FakeAuthApi api;
  ProviderContainer container() => ProviderContainer(
    overrides: [
      secureSessionStoreProvider.overrideWithValue(store),
      authApiProvider.overrideWithValue(api),
    ],
  );
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    store = const SecureSessionStore(FlutterSecureStorage());
    api = FakeAuthApi();
  });

  test('plain debug Run has complete dev config', () {
    expect(AppEnvironment.fromDartDefines().isCloudConfigured, isTrue);
  });
  test(
    'saved login survives provider/app restart without another login',
    () async {
      final first = container();
      await first.read(authControllerProvider.future);
      await first
          .read(authControllerProvider.notifier)
          .signIn(username: 'test-user', password: 'not-stored');
      first.dispose();
      final second = container();
      addTearDown(second.dispose);
      expect(
        (await second.read(authControllerProvider.future))!.subject,
        'test-subject',
      );
      expect(api.refreshCount, 0);
      final values = await const FlutterSecureStorage().readAll();
      expect(values.values.join(), isNot(contains('not-stored')));
    },
  );
  test(
    'expired token rotates and the complete new session is persisted',
    () async {
      await store.saveSession(session(expired: true));
      final c = container();
      addTearDown(c.dispose);
      expect(
        (await c.read(authControllerProvider.future))!.accessToken,
        'rotated',
      );
      expect((await store.readSession())!.refreshToken, 'test-refresh-rotated');
    },
  );
  test(
    'temporary refresh failure retains local session then retries',
    () async {
      await store.saveSession(session(expired: true));
      api.error = const AuthException('NETWORK_ERROR', 'offline');
      final c = container();
      addTearDown(c.dispose);
      expect(await c.read(authControllerProvider.future), isNotNull);
      expect(await store.readSession(), isNotNull);
      await expectLater(
        c.read(authControllerProvider.notifier).validSession(),
        throwsA(isA<AuthException>()),
      );
      api.error = null;
      expect(
        (await c.read(authControllerProvider.notifier).validSession())
            .accessToken,
        'rotated',
      );
    },
  );
  test('only explicit invalid refresh token clears saved session', () async {
    await store.saveSession(session(expired: true));
    api.error = const AuthException('invalid_grant', 'expired');
    final c = container();
    addTearDown(c.dispose);
    expect(await c.read(authControllerProvider.future), isNull);
    expect(await store.readSession(), isNull);
  });
  test(
    'parallel 401 refreshes are coalesced, logout cannot be undone by late refresh',
    () async {
      await store.saveSession(session());
      final c = container();
      addTearDown(c.dispose);
      await c.read(authControllerProvider.future);
      final auth = c.read(authControllerProvider.notifier);
      api.pending = Completer<AuthSession>();
      final one = auth.validSession(rejectedAccessToken: 'test-access');
      final two = auth.validSession(rejectedAccessToken: 'test-access');
      // Attach error handlers before completing the pending network response.
      final oneCheck = expectLater(one, throwsA(isA<AuthException>()));
      final twoCheck = expectLater(two, throwsA(isA<AuthException>()));
      await Future<void>.delayed(Duration.zero);
      expect(api.refreshCount, 1);
      await auth.signOut();
      api.pending!.complete(session(token: 'too-late'));
      await Future.wait([oneCheck, twoCheck]);
      expect(await store.readSession(), isNull);
      expect(c.read(authControllerProvider).requireValue, isNull);
    },
  );
  test(
    'legacy session migrates, logout tombstone prevents resurrection',
    () async {
      FlutterSecureStorage.setMockInitialValues({
        'access_token': 'legacy',
        'refresh_token': 'legacy-refresh',
        'auth_subject': 'subject',
        'auth_username': 'user',
        'access_token_expires_at': DateTime.now()
            .add(const Duration(hours: 1))
            .toIso8601String(),
      });
      expect((await store.readSession())!.accessToken, 'legacy');
      await store.clearSession();
      expect(await store.readSession(), isNull);
    },
  );
  test('different environments do not share saved credentials', () async {
    await store.saveSession(session());
    const other = SecureSessionStore(
      FlutterSecureStorage(),
      namespace: 'other',
      migrateLegacy: false,
    );
    expect(await other.readSession(), isNull);
  });
  test('release gate rejects missing/dev/placeholder/secret configuration', () {
    expect(() => validateReleaseConfig({}), throwsFormatException);
    final prod = <String, String>{
      'APP_FLAVOR': 'prod',
      'CLOUDBASE_ENV_ID': 'test-production-env',
      'AUTH_API_BASE_URL':
          'https://test-production-env.api.tcloudbasegateway.com',
      'FUNCTION_API_BASE_URL':
          'https://test-production-env.service.tcloudbase.com',
    };
    expect(() => validateReleaseConfig(prod), returnsNormally);
    expect(
      () => validateReleaseConfig({...prod, 'APP_FLAVOR': 'dev'}),
      throwsFormatException,
    );
    expect(
      () => validateReleaseConfig({
        ...prod,
        'CLOUDBASE_ENV_ID': AppEnvironment.development.cloudBaseEnvId,
      }),
      throwsFormatException,
    );
    expect(
      () => validateReleaseConfig({
        ...prod,
        'AUTH_API_BASE_URL': 'http://example.com',
      }),
      throwsFormatException,
    );
    expect(
      () => validateReleaseConfig({...prod, 'SECRET_KEY': 'test'}),
      throwsFormatException,
    );
  });
}

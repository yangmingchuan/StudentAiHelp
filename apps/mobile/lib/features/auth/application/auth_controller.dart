import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:little_hero/core/network/api_client.dart';
import 'package:little_hero/core/security/secure_session_store.dart';
import 'package:little_hero/features/auth/data/auth_api.dart';
import 'package:little_hero/features/auth/domain/auth_exception.dart';
import 'package:little_hero/features/auth/domain/auth_session.dart';

final authControllerProvider =
    AsyncNotifierProvider<AuthController, AuthSession?>(AuthController.new);

class AuthController extends AsyncNotifier<AuthSession?> {
  AuthApi get _api => ref.read(authApiProvider);
  SecureSessionStore get _store => ref.read(secureSessionStoreProvider);

  @override
  Future<AuthSession?> build() async {
    final stored = await _store.readSession();
    if (stored == null) {
      return null;
    }
    if (!stored.shouldRefresh) {
      return stored;
    }

    try {
      final refreshed = await _api.refresh(
        refreshToken: stored.refreshToken,
        deviceId: await _store.readOrCreateDeviceId(),
        username: stored.username,
      );
      await _store.saveSession(refreshed);
      return refreshed;
    } catch (_) {
      await _store.clearSession();
      return null;
    }
  }

  Future<void> signIn({
    required String username,
    required String password,
  }) async {
    _ensureConfigured();
    state = const AsyncLoading();
    try {
      final session = await _api.signIn(
        username: username,
        password: password,
        deviceId: await _store.readOrCreateDeviceId(),
      );
      await _store.saveSession(session);
      state = AsyncData(session);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<void> register({
    required String username,
    required String password,
  }) async {
    _ensureConfigured();
    state = const AsyncLoading();
    try {
      await _api.register(username: username, password: password);
      final session = await _api.signIn(
        username: username,
        password: password,
        deviceId: await _store.readOrCreateDeviceId(),
      );
      await _store.saveSession(session);
      state = AsyncData(session);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<void> signOut() async {
    final session = state.asData?.value;
    try {
      if (session != null) {
        await _api.signOut(
          accessToken: session.accessToken,
          deviceId: await _store.readOrCreateDeviceId(),
        );
      }
    } finally {
      await _store.clearSession();
      state = const AsyncData(null);
    }
  }

  void _ensureConfigured() {
    final environment = ref.read(appEnvironmentProvider);
    if (!environment.isCloudConfigured) {
      throw const AuthException(
        'CLOUDBASE_NOT_CONFIGURED',
        '尚未配置 CloudBase dev 环境，请使用项目 README 中的启动参数。',
      );
    }
  }
}

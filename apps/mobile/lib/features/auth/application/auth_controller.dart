import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:little_hero/core/network/api_client.dart';
import 'package:little_hero/core/security/secure_session_store.dart';
import 'package:little_hero/features/auth/data/auth_api.dart';
import 'package:little_hero/features/auth/domain/auth_exception.dart';
import 'package:little_hero/features/auth/domain/auth_session.dart';

final authControllerProvider =
    AsyncNotifierProvider<AuthController, AuthSession?>(AuthController.new);

class AuthController extends AsyncNotifier<AuthSession?> {
  Future<AuthSession>? _refreshing;
  Future<void> _writes = Future<void>.value();
  int _epoch = 0;
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
      return await _refresh(stored, publish: false);
    } on AuthException catch (error) {
      if (error.requiresSignIn) return null;
      // Offline/local-cache access remains available. Network requests must still
      // obtain a valid token through validSession before reaching the server.
      return stored;
    }
  }

  Future<void> _write(Future<void> Function() action) {
    final next = _writes.then(
      (_) => action(),
      onError: (Object _, StackTrace _) => action(),
    );
    _writes = next;
    return next;
  }

  Future<AuthSession> validSession({String? rejectedAccessToken}) async {
    final session = state.asData?.value;
    if (session == null) throw const AuthException('NOT_SIGNED_IN', '请先登录。');
    if (!session.shouldRefresh && rejectedAccessToken != session.accessToken) {
      return session;
    }
    return _refresh(session);
  }

  Future<AuthSession> _refresh(
    AuthSession session, {
    bool publish = true,
  }) async {
    if (_refreshing != null) return _refreshing!;
    final epoch = _epoch;
    final pending = _performRefresh(session, epoch, publish);
    _refreshing = pending;
    try {
      return await pending;
    } finally {
      if (identical(_refreshing, pending)) _refreshing = null;
    }
  }

  Future<AuthSession> _performRefresh(
    AuthSession session,
    int epoch,
    bool publish,
  ) async {
    _ensureConfigured();
    try {
      final refreshed = await _api.refresh(
        refreshToken: session.refreshToken,
        deviceId: await _store.readOrCreateDeviceId(),
        username: session.username,
      );
      if (!ref.mounted || epoch != _epoch) {
        throw const AuthException('SESSION_CHANGED', '登录状态已改变，请重新操作。');
      }
      await _write(() async {
        if (ref.mounted && epoch == _epoch) await _store.saveSession(refreshed);
      });
      if (!ref.mounted || epoch != _epoch) {
        throw const AuthException('SESSION_CHANGED', '登录状态已改变，请重新操作。');
      }
      if (publish) state = AsyncData(refreshed);
      return refreshed;
    } on AuthException catch (error) {
      if (error.requiresSignIn && ref.mounted && epoch == _epoch) {
        await _write(() async {
          if (ref.mounted && epoch == _epoch) await _store.clearSession();
        });
        if (publish && ref.mounted && epoch == _epoch) {
          state = const AsyncData(null);
        }
      }
      rethrow;
    }
  }

  Future<void> signIn({
    required String username,
    required String password,
  }) async {
    _ensureConfigured();
    final epoch = ++_epoch;
    state = const AsyncLoading();
    try {
      final session = await _api.signIn(
        username: username,
        password: password,
        deviceId: await _store.readOrCreateDeviceId(),
      );
      await _write(() async {
        if (ref.mounted && epoch == _epoch) await _store.saveSession(session);
      });
      if (ref.mounted && epoch == _epoch) state = AsyncData(session);
    } catch (error, stackTrace) {
      if (ref.mounted && epoch == _epoch) state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<void> register({
    required String username,
    required String password,
  }) async {
    _ensureConfigured();
    final epoch = ++_epoch;
    state = const AsyncLoading();
    try {
      await _api.register(username: username, password: password);
      final session = await _api.signIn(
        username: username,
        password: password,
        deviceId: await _store.readOrCreateDeviceId(),
      );
      await _write(() async {
        if (ref.mounted && epoch == _epoch) await _store.saveSession(session);
      });
      if (ref.mounted && epoch == _epoch) state = AsyncData(session);
    } catch (error, stackTrace) {
      if (ref.mounted && epoch == _epoch) state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<void> signOut() async {
    final session = state.asData?.value;
    ++_epoch;
    _refreshing = null;
    await _write(_store.clearSession);
    if (ref.mounted) state = const AsyncData(null);
    try {
      if (session != null) {
        await _api.signOut(
          accessToken: session.accessToken,
          deviceId: await _store.readOrCreateDeviceId(),
        );
      }
    } on AuthException {
      // Local logout already succeeded; an unavailable server must not undo it.
    }
  }

  void _ensureConfigured() {
    final environment = ref.read(appEnvironmentProvider);
    if (!environment.isCloudConfigured) {
      throw const AuthException(
        'CLOUDBASE_NOT_CONFIGURED',
        '当前安装包缺少有效的服务配置，请使用带环境配置的版本重新安装。',
      );
    }
  }
}

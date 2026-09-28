import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:little_hero/core/database/local_database.dart';
import 'package:little_hero/core/network/api_client.dart';
import 'package:little_hero/core/security/sensitive_field_cipher.dart';
import 'package:little_hero/features/auth/application/auth_controller.dart';
import 'todo_sync_store.dart';

final todoSyncProvider = Provider<TodoSyncService?>((ref) {
  final owner = ref.watch(
    authControllerProvider.select((s) => s.asData?.value?.subject),
  );
  if (owner == null || !ref.watch(appEnvironmentProvider).usesSupabase) {
    return null;
  }
  final db = ref.watch(localDatabaseProvider);
  final dio = ref.watch(functionDioProvider);
  final service = TodoSyncService(
    TodoSyncStore(db, ref.watch(sensitiveFieldCipherProvider)),
    (cursor, changes) async {
      final auth = ref.read(authControllerProvider.notifier);
      var session = await auth.validSession();
      if (session.subject != owner) throw StateError('账号已切换');
      Future<Response<Map<String, dynamic>>> request() => dio.post(
        '/rest/v1/rpc/todo_sync',
        data: {'p_cursor': cursor, 'p_changes': changes},
        options: Options(
          headers: {'Authorization': 'Bearer ${session.accessToken}'},
        ),
      );
      try {
        return (await request()).data!;
      } on DioException catch (error) {
        if (error.response?.statusCode != 401) rethrow;
        session = await auth.validSession(
          rejectedAccessToken: session.accessToken,
        );
        if (session.subject != owner) throw StateError('账号已切换');
        return (await request()).data!;
      }
    },
  );
  ref.onDispose(service.close);
  return service;
});

typedef SyncTransport =
    Future<Map<String, dynamic>> Function(
      int cursor,
      List<Map<String, dynamic>> changes,
    );

class TodoSyncService {
  TodoSyncService(this.store, this.transport) {
    _subscription = store.db.tableUpdates().listen((_) => requestSoon());
  }
  final TodoSyncStore store;
  final SyncTransport transport;
  final status = ValueNotifier<String>('等待同步');
  final updates = StreamController<void>.broadcast();
  StreamSubscription<Object?>? _subscription;
  Timer? _debounce;
  Timer? _periodic;
  Future<bool>? _running;
  bool _closed = false;
  int conflicts = 0;
  void setActive(bool active) {
    _periodic?.cancel();
    if (active && !_closed) {
      unawaited(synchronize());
      _periodic = Timer.periodic(
        const Duration(seconds: 15),
        (_) => unawaited(synchronize()),
      );
    }
  }

  void requestSoon() {
    if (_closed) return;
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 600),
      () => unawaited(synchronize()),
    );
  }

  Future<bool> synchronize() {
    if (_closed) return Future.value(false);
    return _running ??= _sync().whenComplete(() => _running = null);
  }

  Future<bool> _sync() async {
    status.value = '正在同步';
    try {
      var changed = false;
      var more = true;
      while (more && !_closed) {
        final changes = await store.pending();
        final response = await transport(await store.cursor(), changes);
        if (_closed) return false;
        changed = await store.apply(response) || changed;
        more =
            response['has_more'] == true || (await store.pending()).isNotEmpty;
      }
      if (_closed) return false;
      conflicts = await store.conflictCount();
      status.value = conflicts > 0 ? '有 $conflicts 条修改需要确认' : '已同步到云端';
      if (changed) updates.add(null);
      return true;
    } catch (error) {
      // Do not log record payloads, tokens, or health text from an exception.
      debugPrint(
        'Todo 同步失败: ${error.runtimeType}'
        '${error is DioException ? ' HTTP ${error.response?.statusCode ?? '无响应'}' : ''}',
      );
      if (!_closed) status.value = '尚未同步，记录已保存在本机，联网后重试';
      return false;
    }
  }

  Future<void> resolve({required bool keepLocal}) async {
    if (_running != null) await _running;
    if (_closed) return;
    await store.resolveConflicts(keepLocal: keepLocal);
    updates.add(null);
    await synchronize();
  }

  void close() {
    _closed = true;
    _debounce?.cancel();
    _periodic?.cancel();
    _subscription?.cancel();
    updates.close();
  }
}

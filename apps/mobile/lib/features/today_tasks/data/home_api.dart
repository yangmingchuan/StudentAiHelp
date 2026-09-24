import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:little_hero/core/network/api_client.dart';
import 'package:little_hero/features/auth/application/auth_controller.dart';

final homeApiProvider = Provider<HomeApi>((ref) {
  return HomeApi(ref.watch(functionDioProvider), ref);
});

class HomeApi {
  const HomeApi(this._dio, this._ref);

  final Dio _dio;
  final Ref _ref;

  Future<Map<String, dynamic>> bootstrap() async {
    return _authorized(
      (options) =>
          _dio.get<Map<String, dynamic>>('/api/bootstrap', options: options),
    );
  }

  Future<Map<String, dynamic>> submitTaskStatus({
    required String operationId,
    required int childId,
    required int taskId,
    required String status,
  }) async {
    return _authorized(
      (options) => _dio.post<Map<String, dynamic>>(
        '/api/tasks/record',
        data: {
          'operationId': operationId,
          'childId': childId,
          'taskId': taskId,
          'status': status,
        },
        options: options,
      ),
    );
  }

  Future<Map<String, dynamic>> submitTaskManagement({
    required String operationId,
    required String action,
    required Map<String, Object?> payload,
  }) async {
    return _authorized(
      (options) => _dio.post<Map<String, dynamic>>(
        '/api/tasks/manage',
        data: {'operationId': operationId, 'action': action, ...payload},
        options: options,
      ),
    );
  }

  Future<Map<String, dynamic>> _authorized(
    Future<Response<Map<String, dynamic>>> Function(Options) request,
  ) async {
    final auth = _ref.read(authControllerProvider.notifier);
    final session = await auth.validSession();
    Options headers(String token) =>
        Options(headers: {'Authorization': 'Bearer $token'});
    try {
      return _data((await request(headers(session.accessToken))).data);
    } on DioException catch (error) {
      if (error.response?.statusCode != 401) rethrow;
      // Exactly one retry. Existing operationId is retained for idempotent writes.
      final refreshed = await auth.validSession(
        rejectedAccessToken: session.accessToken,
      );
      return _data((await request(headers(refreshed.accessToken))).data);
    }
  }

  Map<String, dynamic> _data(Map<String, dynamic>? body) {
    final value = body?['data'];
    if (value is Map<String, dynamic>) {
      return value;
    }
    return const <String, dynamic>{};
  }
}

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
    final session = _ref.read(authControllerProvider).asData?.value;
    if (session == null) {
      throw StateError('Not signed in');
    }

    final response = await _dio.get<Map<String, dynamic>>(
      '/api/bootstrap',
      options: Options(
        headers: {'Authorization': 'Bearer ${session.accessToken}'},
      ),
    );
    return _data(response.data);
  }

  Future<Map<String, dynamic>> submitTaskStatus({
    required String operationId,
    required int childId,
    required int taskId,
    required String status,
  }) async {
    final session = _ref.read(authControllerProvider).asData?.value;
    if (session == null) {
      throw StateError('Not signed in');
    }

    final response = await _dio.post<Map<String, dynamic>>(
      '/api/tasks/record',
      data: {
        'operationId': operationId,
        'childId': childId,
        'taskId': taskId,
        'status': status,
      },
      options: Options(
        headers: {'Authorization': 'Bearer ${session.accessToken}'},
      ),
    );
    return _data(response.data);
  }

  Future<Map<String, dynamic>> submitTaskManagement({
    required String operationId,
    required String action,
    required Map<String, Object?> payload,
  }) async {
    final session = _ref.read(authControllerProvider).asData?.value;
    if (session == null) {
      throw StateError('Not signed in');
    }

    final response = await _dio.post<Map<String, dynamic>>(
      '/api/tasks/manage',
      data: {
        'operationId': operationId,
        'action': action,
        ...payload,
      },
      options: Options(
        headers: {'Authorization': 'Bearer ${session.accessToken}'},
      ),
    );
    return _data(response.data);
  }

  Map<String, dynamic> _data(Map<String, dynamic>? body) {
    final value = body?['data'];
    if (value is Map<String, dynamic>) {
      return value;
    }
    return const <String, dynamic>{};
  }
}

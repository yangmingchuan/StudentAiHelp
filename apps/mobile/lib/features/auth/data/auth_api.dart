import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:little_hero/core/network/api_client.dart';
import 'package:little_hero/features/auth/domain/auth_exception.dart';
import 'package:little_hero/features/auth/domain/auth_session.dart';

final authApiProvider = Provider<AuthApi>((ref) {
  return AuthApi(
    ref.watch(authDioProvider),
    ref.watch(functionDioProvider),
    supabase: ref.watch(appEnvironmentProvider).usesSupabase,
  );
});

class AuthApi {
  const AuthApi(this._authDio, this._functionDio, {this.supabase = false});
  final bool supabase;

  final Dio _authDio;
  final Dio _functionDio;

  Future<AuthSession> signIn({
    required String username,
    required String password,
    required String deviceId,
  }) async {
    try {
      if (supabase) {
        try {
          final response = await _authDio.post<Map<String, dynamic>>(
            '/auth/v1/token?grant_type=password',
            data: {
              'email': 'todo.$username@accounts.little-hero.invalid',
              'password': password,
            },
          );
          return _parseSession(response.data, username: username);
        } on DioException catch (error) {
          final body = error.response?.data;
          if (body is! Map ||
              body['error_code'] != 'invalid_credentials' &&
                  body['code'] != 'invalid_credentials' &&
                  body['error'] != 'invalid_credentials') {
            rethrow;
          }
          final migrated = await _functionDio.post<Map<String, dynamic>>(
            '/functions/v1/todo-auth',
            data: {
              'action': 'migrate',
              'username': username,
              'password': password,
            },
          );
          return _parseSession(migrated.data, username: username);
        }
      }
      final response = await _authDio.post<Map<String, dynamic>>(
        '/auth/v1/token',
        data: {
          'grant_type': 'password',
          'username': username,
          'password': password,
        },
        options: Options(headers: {'x-device-id': deviceId}),
      );
      return _parseSession(response.data, username: username);
    } on DioException catch (error) {
      throw _mapError(error);
    }
  }

  Future<void> register({
    required String username,
    required String password,
  }) async {
    try {
      await _functionDio.post<Map<String, dynamic>>(
        supabase ? '/functions/v1/todo-auth' : '/api/auth/register',
        data: {
          'username': username,
          'password': password,
          'privacyAccepted': true,
          if (supabase) 'action': 'register',
        },
      );
    } on DioException catch (error) {
      throw _mapError(error);
    }
  }

  Future<AuthSession> refresh({
    required String refreshToken,
    required String deviceId,
    required String username,
  }) async {
    try {
      final response = await _authDio.post<Map<String, dynamic>>(
        supabase ? '/auth/v1/token?grant_type=refresh_token' : '/auth/v1/token',
        data: {
          if (!supabase) 'grant_type': 'refresh_token',
          'refresh_token': refreshToken,
        },
        options: Options(headers: {'x-device-id': deviceId}),
      );
      return _parseSession(
        response.data,
        fallbackRefreshToken: refreshToken,
        username: username,
      );
    } on DioException catch (error) {
      throw _mapError(error);
    }
  }

  Future<void> signOut({
    required String accessToken,
    required String deviceId,
  }) async {
    try {
      await _authDio.post<Map<String, dynamic>>(
        supabase ? '/auth/v1/logout?scope=local' : '/auth/v1/user/signout',
        data: const <String, dynamic>{},
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'x-device-id': deviceId,
          },
        ),
      );
    } on DioException catch (error) {
      throw _mapError(error);
    }
  }

  AuthSession _parseSession(
    Map<String, dynamic>? data, {
    String? fallbackRefreshToken,
    required String username,
  }) {
    final session = AuthSession.fromTokenResponse(
      data ?? const <String, dynamic>{},
      fallbackRefreshToken: fallbackRefreshToken,
      username: username,
    );
    if (session.accessToken.isEmpty ||
        session.refreshToken.isEmpty ||
        session.subject.isEmpty) {
      throw const AuthException('INVALID_AUTH_RESPONSE', '登录服务返回了无效会话，请稍后重试。');
    }
    return session;
  }

  AuthException _mapError(DioException error) {
    // A gateway failure is not evidence that the user's refresh token expired.
    if ((error.response?.statusCode ?? 0) >= 500) {
      return const AuthException(
        'AUTH_SERVICE_UNAVAILABLE',
        '登录服务暂时不可用，请稍后重试。',
      );
    }
    final data = error.response?.data;
    if (data is Map) {
      final code =
          data['error_code']?.toString() ??
          data['code']?.toString() ??
          data['error']?.toString() ??
          'AUTH_REQUEST_FAILED';
      final serverMessage =
          data['message']?.toString() ??
          data['msg']?.toString() ??
          data['error_description']?.toString();

      if (code == 'INVALID_USERNAME_OR_PASSWORD' ||
          code == 'invalid_username_or_password' ||
          code == 'invalid_credentials') {
        return const AuthException('INVALID_USERNAME_OR_PASSWORD', '账号或密码不正确。');
      }
      if (code == 'USERNAME_ALREADY_EXISTS') {
        return const AuthException('USERNAME_ALREADY_EXISTS', '该账号已注册，请直接登录。');
      }
      if (code == 'RATE_LIMITED') {
        return const AuthException('RATE_LIMITED', '尝试次数过多，请稍后再试。');
      }
      if (serverMessage != null && serverMessage.isNotEmpty) {
        return AuthException(code, serverMessage);
      }
    }

    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return const AuthException('NETWORK_ERROR', '网络连接失败，请检查网络后重试。');
    }

    return const AuthException('AUTH_REQUEST_FAILED', '操作失败，请稍后重试。');
  }
}

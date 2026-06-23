import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:little_hero/core/config/app_environment.dart';

final appEnvironmentProvider = Provider<AppEnvironment>((ref) {
  return AppEnvironment.fromDartDefines();
});

final authDioProvider = Provider<Dio>((ref) {
  final environment = ref.watch(appEnvironmentProvider);

  return Dio(
    BaseOptions(
      baseUrl: environment.authApiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: const {'Accept': 'application/json'},
    ),
  );
});

final functionDioProvider = Provider<Dio>((ref) {
  final environment = ref.watch(appEnvironmentProvider);

  return Dio(
    BaseOptions(
      baseUrl: environment.functionApiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: const {'Accept': 'application/json'},
    ),
  );
});

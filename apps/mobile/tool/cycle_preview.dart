// Isolated visual QA entry point. All records are fictional and in memory.
// flutter run -t tool/cycle_preview.dart -d <simulator>
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:little_hero/app/app.dart';
import 'package:little_hero/app/router.dart';
import 'package:little_hero/core/database/local_database.dart';
import 'package:little_hero/core/sync/operation_id_factory.dart';
import 'package:little_hero/features/auth/application/auth_controller.dart';
import 'package:little_hero/features/auth/domain/auth_session.dart';
import 'package:little_hero/features/mama_tools/data/cycle_repository.dart';
import 'package:little_hero/features/mama_tools/domain/cycle_models.dart';
import 'package:little_hero/features/today_tasks/application/home_controller.dart';
import 'package:little_hero/features/today_tasks/domain/home_snapshot.dart';
import 'package:uuid/uuid.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = LocalDatabase.forTesting(NativeDatabase.memory());
  final repository = CycleRepository(db, const OperationIdFactory(Uuid()));
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, now.day - 17);
  await repository.saveSetup(
    CycleProfileDraft(
      lastPeriodStartDate: start,
      periodLengthDays: 5,
      cycleLengthDays: 28,
    ),
  );
  for (var i = 0; i < 5; i++) {
    await repository.saveRecord(
      date: DateTime(start.year, start.month, start.day + i),
      flow: i < 2 ? CycleFlow.medium : CycleFlow.light,
      symptoms: i == 0 ? ['疲倦'] : [],
      diaryText: i == 0 ? '示例记录：今天早点休息' : '',
    );
  }
  final container = ProviderContainer(
    overrides: [
      localDatabaseProvider.overrideWithValue(db),
      authControllerProvider.overrideWith(_PreviewAuth.new),
      homeControllerProvider.overrideWith(_PreviewHome.new),
    ],
  );
  await container.read(authControllerProvider.future);
  container
      .read(appRouterProvider)
      .go(const String.fromEnvironment('PREVIEW_ROUTE', defaultValue: '/mama'));
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const LittleHeroApp(),
    ),
  );
}

class _PreviewAuth extends AuthController {
  @override
  Future<AuthSession?> build() async => AuthSession(
    accessToken: 'preview-only',
    refreshToken: 'preview-only',
    subject: 'preview',
    username: '示例',
    expiresAt: DateTime.now().add(const Duration(days: 1)),
  );
}

class _PreviewHome extends HomeController {
  @override
  Future<HomeSnapshot> build() async => const HomeSnapshot(
    child: ChildSummary(
      id: 1,
      nickname: '示例',
      avatarIcon: 'face_rounded',
      avatarColor: 'green',
      needsProfileSetup: false,
    ),
    assets: AssetSummary(
      availableStars: 0,
      lifetimeStars: 0,
      badgeCount: 0,
      heartsRemaining: 10,
      heartsLimit: 10,
    ),
    tasks: [
      TaskSummary(
        id: 1,
        name: '自己刷牙',
        iconName: 'brush',
        sortOrder: 1,
        status: TaskStatus.none,
      ),
    ],
    badges: BadgeSummary(earnedCount: 0, totalCount: 3),
    isStale: false,
    isSyncing: false,
  );
}

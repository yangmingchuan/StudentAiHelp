import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:little_hero/core/database/local_database.dart';
import 'package:little_hero/core/sync/operation_id_factory.dart';
import 'package:little_hero/core/theme/app_theme.dart';
import 'package:little_hero/features/mama_tools/application/cycle_controller.dart';
import 'package:little_hero/features/mama_tools/data/cycle_repository.dart';
import 'package:little_hero/features/mama_tools/domain/cycle_models.dart';
import 'package:little_hero/features/mama_tools/presentation/cycle_diary_page.dart';
import 'package:little_hero/features/mama_tools/presentation/mama_tools_page.dart';
import 'package:uuid/uuid.dart';

void main() {
  testWidgets('setup and calendar fit a narrow screen with enlarged text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final db = LocalDatabase.forTesting(NativeDatabase.memory());
    final repository = CycleRepository(db, const OperationIdFactory(Uuid()));
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [cycleRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    await tester.runAsync(() => container.read(cycleControllerProvider.future));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.5)),
            child: child!,
          ),
          home: const Scaffold(body: MamaToolsPage()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.runAsync(() async {
      await repository.saveSetup(
        CycleProfileDraft(
          lastPeriodStartDate: DateTime(2026, 1, 1),
          periodLengthDays: 5,
          cycleLengthDays: 28,
        ),
      );
      container.invalidate(cycleControllerProvider);
      await container.read(cycleControllerProvider.future);
    });
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -450));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'date-specific editor loads and persists flow, symptoms and notes',
    (tester) async {
      final db = LocalDatabase.forTesting(NativeDatabase.memory());
      final repository = CycleRepository(db, const OperationIdFactory(Uuid()));
      addTearDown(db.close);
      final today = cycleDateOnly(DateTime.now());
      final yesterday = DateTime(today.year, today.month, today.day - 1);
      final container = ProviderContainer(
        overrides: [cycleRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);
      await tester.runAsync(() async {
        await repository.saveSetup(
          CycleProfileDraft(
            lastPeriodStartDate: yesterday,
            periodLengthDays: 5,
            cycleLengthDays: 28,
          ),
        );
        await repository.saveRecord(
          date: yesterday,
          flow: CycleFlow.light,
          symptoms: ['疲倦'],
          diaryText: '昨天',
        );
        await repository.saveRecord(
          date: today,
          flow: CycleFlow.medium,
          symptoms: [],
          diaryText: '今天',
        );
        await container.read(cycleControllerProvider.future);
        final subscription = container.listen(
          cycleDayProvider(yesterday),
          (_, _) {},
        );
        addTearDown(subscription.close);
        await container.read(cycleDayProvider(yesterday).future);
      });
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.light,
            home: CycleDiaryPage(date: yesterday),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('昨天'), findsOneWidget);
      expect(find.text('今天'), findsNothing);
      await tester.tap(find.widgetWithText(ChoiceChip, '中等'));
      await tester.ensureVisible(find.byType(TextField));
      await tester.enterText(find.byType(TextField), '补充昨天的感受');
      await tester.runAsync(() async {
        await tester.tap(find.text('保存'));
        // Wait for the real save to finish by polling the provider's updated snapshot.
        for (var i = 0; i < 50; i++) {
          if ((await repository.loadDay(yesterday)).diaryText == '补充昨天的感受') {
            break;
          }
          await Future<void>.delayed(const Duration(milliseconds: 10));
        }
        final day = await repository.loadDay(yesterday);
        expect(day.diaryText, '补充昨天的感受');
        expect(day.flow, CycleFlow.medium);
        expect(day.symptoms, ['疲倦']);
        expect((await repository.loadDay(today)).diaryText, '今天');
      });
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}

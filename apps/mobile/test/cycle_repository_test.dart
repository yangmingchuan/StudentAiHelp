import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:little_hero/core/database/local_database.dart';
import 'package:little_hero/core/sync/operation_id_factory.dart';
import 'package:little_hero/features/mama_tools/application/cycle_controller.dart';
import 'package:little_hero/features/mama_tools/data/cycle_repository.dart';
import 'package:little_hero/features/mama_tools/domain/cycle_models.dart';
import 'package:uuid/uuid.dart';

void main() {
  late LocalDatabase db;
  late CycleRepository repository;
  final today = cycleDateOnly(DateTime.now());
  final yesterday = DateTime(today.year, today.month, today.day - 1);
  setUp(() {
    db = LocalDatabase.forTesting(NativeDatabase.memory());
    repository = CycleRepository(db, const OperationIdFactory(Uuid()));
  });
  tearDown(() async => db.close());
  Future<void> setup([DateTime? start]) => repository.saveSetup(
    CycleProfileDraft(
      lastPeriodStartDate: start ?? yesterday,
      periodLengthDays: 5,
      cycleLengthDays: 28,
    ),
  );
  Future<CycleSnapshot> load(DateTime date) =>
      repository.load(visibleMonth: date, selectedDate: date);

  test('setup does not require or fabricate a birthday', () async {
    expect((await load(today)).needsSetup, isTrue);
    expect(await db.select(db.localCycleProfiles).get(), isEmpty);
    await setup();
    final result = await load(today);
    expect(result.needsSetup, isFalse);
    expect(result.profile!.birthDate, isNull);
    expect(await db.select(db.syncOperations).get(), isEmpty);
  });
  test(
    'future period start and future records are rejected without partial writes',
    () async {
      await setup();
      final future = DateTime(today.year, today.month, today.day + 1);
      await expectLater(setup(future), throwsArgumentError);
      await expectLater(
        repository.saveRecord(
          date: future,
          flow: CycleFlow.light,
          symptoms: [],
          diaryText: '',
        ),
        throwsArgumentError,
      );
      expect((await load(today)).profile!.lastPeriodStartDate, yesterday);
      expect((await load(today)).records, isEmpty);
    },
  );
  test(
    'diary updates preserve flow and symptoms; route dates load independently',
    () async {
      await setup();
      await repository.saveRecord(
        date: yesterday,
        flow: CycleFlow.medium,
        symptoms: ['疲倦'],
        diaryText: '昨天的记录',
      );
      await repository.saveRecord(
        date: today,
        flow: CycleFlow.light,
        symptoms: [],
        diaryText: '今天的记录',
      );
      await repository.saveDiary(date: yesterday, diaryText: '补充昨天');
      final oldDay = await repository.loadDay(yesterday);
      expect(oldDay.diaryText, '补充昨天');
      expect(oldDay.flow, CycleFlow.medium);
      expect(oldDay.symptoms, ['疲倦']);
      expect((await repository.loadDay(today)).diaryText, '今天的记录');
    },
  );
  test(
    'confirmed new start updates prediction and preserves old daily records',
    () async {
      final oldStart = DateTime(today.year, today.month, today.day - 30);
      await setup(oldStart);
      await repository.saveRecord(
        date: oldStart,
        flow: CycleFlow.heavy,
        symptoms: [],
        diaryText: '上次',
      );
      await repository.saveRecord(
        date: today,
        flow: CycleFlow.light,
        symptoms: [],
        diaryText: '这次',
        startsPeriod: true,
      );
      final result = await load(today);
      expect(result.records.length, 2);
      expect(result.profile!.lastPeriodStartDate, today);
      expect(
        result.nextPeriodDate,
        DateTime(today.year, today.month, today.day + 28),
      );
      await expectLater(
        repository.saveRecord(
          date: oldStart,
          flow: CycleFlow.light,
          symptoms: [],
          diaryText: '不应覆盖',
          startsPeriod: true,
        ),
        throwsArgumentError,
      );
      expect((await repository.loadDay(oldStart)).diaryText, '上次');
    },
  );
  test(
    'unrecorded inferred days are predictions, not confirmed periods',
    () async {
      await setup();
      expect(
        (await repository.loadDay(today)).phase,
        CyclePhase.predictedPeriod,
      );
      await repository.saveRecord(
        date: today,
        flow: CycleFlow.noBleeding,
        symptoms: [],
        diaryText: '',
      );
      expect((await repository.loadDay(today)).phase, CyclePhase.normal);
      expect(
        (await repository.loadDay(
          DateTime(yesterday.year, yesterday.month, yesterday.day - 28),
        )).phase,
        CyclePhase.normal,
      );
    },
  );
  test(
    'latest period stays continuous across elapsed days and month boundaries',
    () async {
      final start = DateTime(2024, 12, 29);
      await setup(start);
      final snapshot = await load(DateTime(start.year + 1, 1, 1));
      for (var offset = 0; offset < 5; offset++) {
        final date = DateTime(start.year, start.month, start.day + offset);
        final expected = offset == 0
            ? CyclePhase.menstrual
            : CyclePhase.predictedPeriod;
        expect((await repository.loadDay(date)).phase, expected);
        expect(
          snapshot.calendarDays
              .singleWhere((day) => day.date == date)
              .info
              .phase,
          expected,
        );
      }
      final noBleeding = DateTime(start.year, start.month, start.day + 2);
      await repository.saveRecord(
        date: noBleeding,
        flow: CycleFlow.noBleeding,
        symptoms: [],
        diaryText: '',
      );
      expect((await repository.loadDay(noBleeding)).phase, CyclePhase.normal);
      for (final offset in [-1, 5, 28]) {
        expect(
          (await repository.loadDay(
            DateTime(start.year, start.month, start.day + offset),
          )).phase,
          CyclePhase.normal,
        );
      }
    },
  );

  test(
    'calendar includes leap day and changing months keeps selection visible',
    () async {
      await setup(DateTime(2024, 1, 1));
      final container = ProviderContainer(
        overrides: [cycleRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);
      await container.read(cycleControllerProvider.future);
      final controller = container.read(cycleControllerProvider.notifier);
      await controller.selectDate(DateTime(2024, 1, 31));
      await controller.nextMonth();
      var snapshot = container.read(cycleControllerProvider).requireValue;
      expect(snapshot.selectedDate, DateTime(2024, 2, 29));
      expect(snapshot.calendarDays.length, 42);
      expect(
        snapshot.calendarDays.where((d) => d.isSelected).single.date,
        snapshot.selectedDate,
      );
      await controller.goToToday();
      snapshot = container.read(cycleControllerProvider).requireValue;
      expect(snapshot.selectedDate, today);
    },
  );
}

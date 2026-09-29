import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:little_hero/core/database/local_database.dart';
import 'package:little_hero/core/security/sensitive_field_cipher.dart';
import 'package:little_hero/core/sync/operation_id_factory.dart';
import 'package:little_hero/features/mama_tools/domain/cycle_models.dart';

final cycleRepositoryProvider = Provider<CycleRepository>(
  (ref) => CycleRepository(
    ref.watch(localDatabaseProvider),
    ref.watch(operationIdFactoryProvider),
    ref.watch(sensitiveFieldCipherProvider),
  ),
);

class CycleRepository {
  const CycleRepository(this._db, this._operationIdFactory, [this._cipher]);
  final LocalDatabase _db;
  final OperationIdFactory _operationIdFactory;
  final SensitiveFieldCipher? _cipher;

  Future<CycleSnapshot> load({
    required DateTime visibleMonth,
    required DateTime selectedDate,
  }) async {
    final profile = await _loadProfileSummary();
    final today = cycleDateOnly(DateTime.now());
    final month = DateTime(visibleMonth.year, visibleMonth.month);
    final selected = cycleDateOnly(selectedDate);
    final logs = await (_db.select(
      _db.localCycleDayLogs,
    )..orderBy([(t) => OrderingTerm.desc(t.logDate)])).get();
    final byDate = {for (final log in logs) log.logDate: await _readLog(log)};
    final selectedDay = _dayInfo(
      selected,
      profile,
      byDate[cycleDateKey(selected)],
      today,
    );
    // Calendar constructors keep date arithmetic correct across DST transitions.
    final start = DateTime(month.year, month.month, 1 - month.weekday % 7);
    return CycleSnapshot(
      needsSetup: profile == null,
      profile: profile,
      today: today,
      visibleMonth: month,
      selectedDate: selected,
      calendarDays: [
        for (var i = 0; i < 42; i++)
          () {
            final date = DateTime(start.year, start.month, start.day + i);
            return CycleCalendarDay(
              date: date,
              isInVisibleMonth: date.month == month.month,
              isToday: date == today,
              isSelected: date == selected,
              info: _dayInfo(date, profile, byDate[cycleDateKey(date)], today),
            );
          }(),
      ],
      selectedDay: selectedDay,
      dailyAdvice: selectedDay.advice,
      records: [
        for (final log in logs)
          _dayInfo(
            DateTime.parse(log.logDate),
            profile,
            byDate[log.logDate],
            today,
          ),
      ].where((day) => day.hasRecord).toList(),
    );
  }

  Future<CycleDayInfo> loadDay(DateTime date) async =>
      (await load(visibleMonth: date, selectedDate: date)).selectedDay;
  Future<void> saveSetup(CycleProfileDraft draft) => saveSettings(draft);

  Future<void> saveSettings(CycleProfileDraft draft) async {
    _validateDraft(draft);
    await _db.transaction(() async {
      await _ensureProfileRow();
      await (_db.update(
        _db.localCycleProfiles,
      )..where((t) => t.id.equals(1))).write(
        LocalCycleProfilesCompanion(
          lastPeriodStartDate: Value(
            await _encrypt(cycleDateKey(draft.lastPeriodStartDate)),
          ),
          periodLengthDays: Value(draft.periodLengthDays),
          cycleLengthDays: Value(draft.cycleLengthDays),
          birthDate: draft.birthDate == null
              ? const Value.absent()
              : Value(await _encrypt(cycleDateKey(draft.birthDate!))),
          isSetupComplete: const Value(true),
          updatedAt: Value(DateTime.now()),
        ),
      );
    });
  }

  Future<void> saveRecord({
    required DateTime date,
    required CycleFlow flow,
    required List<String> symptoms,
    required String diaryText,
    bool startsPeriod = false,
  }) async {
    final day = cycleDateOnly(date);
    if (day.isAfter(cycleDateOnly(DateTime.now()))) {
      throw ArgumentError('还不能记录未来的身体情况，请选择今天或之前的日期');
    }
    if (diaryText.trim().length > 500) throw ArgumentError('备注请控制在 500 字以内');
    if (startsPeriod && !flow.isBleeding) throw ArgumentError('经期开始日需要填写经量');
    await _db.transaction(() async {
      await _ensureProfileRow();
      final profile = await _loadProfileSummary();
      if (profile == null) throw StateError('请先完成经期设置');
      if (startsPeriod && day.isBefore(profile.lastPeriodStartDate)) {
        throw ArgumentError('补记历史经期请只填写经量；最近开始日期可在周期设置中修正');
      }
      await _db
          .into(_db.localCycleDayLogs)
          .insertOnConflictUpdate(
            LocalCycleDayLogsCompanion.insert(
              logDate: cycleDateKey(day),
              diaryText: Value(await _encrypt(diaryText.trim())),
              flowLevel: Value(flow.value),
              symptomsJson: Value(
                await _encrypt(jsonEncode(symptoms.toSet().toList())),
              ),
              operationId: Value(_operationIdFactory.create()),
              // The account sync outbox is populated by the database trigger.
              isDirty: const Value(false),
              updatedAt: Value(DateTime.now()),
            ),
          );
      if (startsPeriod) {
        await (_db.update(
          _db.localCycleProfiles,
        )..where((t) => t.id.equals(1))).write(
          LocalCycleProfilesCompanion(
            lastPeriodStartDate: Value(await _encrypt(cycleDateKey(day))),
            updatedAt: Value(DateTime.now()),
          ),
        );
      }
    });
  }

  Future<void> saveDiary({
    required DateTime date,
    required String diaryText,
  }) async {
    final day = await loadDay(date);
    await saveRecord(
      date: date,
      flow: day.flow,
      symptoms: day.symptoms,
      diaryText: diaryText,
    );
  }

  Future<LocalCycleProfile?> _profileRow() => (_db.select(
    _db.localCycleProfiles,
  )..where((t) => t.id.equals(1))).getSingleOrNull();
  Future<void> _ensureProfileRow() async {
    await _db
        .into(_db.localCycleProfiles)
        .insert(
          LocalCycleProfilesCompanion.insert(id: const Value(1)),
          mode: InsertMode.insertOrIgnore,
        );
  }

  CycleDayInfo _dayInfo(
    DateTime date,
    CycleProfileSummary? profile,
    _CycleLogContent? log,
    DateTime today,
  ) {
    final flow = CycleFlow.parse(log?.flowLevel ?? 'none');
    final diary = log?.diaryText ?? '';
    List<String> symptoms;
    try {
      symptoms = (jsonDecode(log?.symptomsJson ?? '[]') as List)
          .whereType<String>()
          .toList();
    } on FormatException {
      symptoms = [];
    } on TypeError {
      symptoms = [];
    }
    final elapsed = profile == null
        ? -1
        : cycleDaysBetween(date, profile.lastPeriodStartDate);
    final isStart =
        profile != null && date == cycleDateOnly(profile.lastPeriodStartDate);
    final predicted =
        profile != null &&
        elapsed >= 0 &&
        !date.isBefore(today) &&
        elapsed % profile.cycleLengthDays < profile.periodLengthDays;
    final phase = profile == null
        ? CyclePhase.setup
        : flow.isBleeding || (isStart && flow == CycleFlow.unlogged)
        ? CyclePhase.menstrual
        : flow == CycleFlow.noBleeding
        ? CyclePhase.normal
        : predicted
        ? CyclePhase.predictedPeriod
        : CyclePhase.normal;
    return CycleDayInfo(
      date: date,
      cycleDay: elapsed < 0 ? 0 : elapsed + 1,
      phase: phase,
      tags: [phase.label],
      flow: flow,
      symptoms: symptoms,
      summary: switch (phase) {
        CyclePhase.setup => '先设置最近一次经期，开始记录自己的节奏',
        CyclePhase.menstrual =>
          flow.isBleeding ? '经期已记录 · ${flow.label}' : '经期开始日',
        CyclePhase.predictedPeriod => '预计经期，实际日期可能变化',
        _ => flow == CycleFlow.noBleeding ? '已记录无经血' : '留意今天的身体感受',
      },
      advice: phase == CyclePhase.menstrual
          ? '按自己的舒适程度安排活动和休息，记录经量与不适，方便回顾。'
          : phase == CyclePhase.predictedPeriod
          ? '可以提前准备经期用品。预测基于你填写的日期和周期长度，实际日期可能不同。'
          : '每天留一点时间照顾自己。经量、睡眠和心情的记录，有助于回顾变化。',
      diaryText: diary,
      hasDiary: diary.trim().isNotEmpty,
    );
  }

  Future<CycleProfileSummary?> _loadProfileSummary() async {
    final row = await _profileRow();
    if (row == null ||
        !row.isSetupComplete ||
        row.lastPeriodStartDate == null) {
      return null;
    }
    final lastPeriod = await _readAndMigrateProfileDate(
      row.lastPeriodStartDate,
      isLastPeriod: true,
    );
    final birthDate = await _readAndMigrateProfileDate(
      row.birthDate,
      isLastPeriod: false,
    );
    final parsedLastPeriod = DateTime.tryParse(lastPeriod ?? '');
    if (parsedLastPeriod == null) return null;
    return CycleProfileSummary(
      lastPeriodStartDate: parsedLastPeriod,
      periodLengthDays: row.periodLengthDays,
      cycleLengthDays: row.cycleLengthDays,
      birthDate: DateTime.tryParse(birthDate ?? ''),
      cloudSyncEnabled: row.cloudSyncEnabled,
    );
  }

  Future<String?> _readAndMigrateProfileDate(
    String? value, {
    required bool isLastPeriod,
  }) async {
    if (value == null) return null;
    final clear = await _decrypt(value);
    if (value.isNotEmpty && !_isProtected(value)) {
      await (_db.update(
        _db.localCycleProfiles,
      )..where((t) => t.id.equals(1))).write(
        LocalCycleProfilesCompanion(
          lastPeriodStartDate: isLastPeriod
              ? Value(await _encrypt(value))
              : const Value.absent(),
          birthDate: isLastPeriod
              ? const Value.absent()
              : Value(await _encrypt(value)),
          updatedAt: Value(DateTime.now()),
        ),
      );
    }
    return clear;
  }

  Future<_CycleLogContent> _readLog(LocalCycleDayLog row) async {
    final diary = await _decrypt(row.diaryText);
    final symptomsJson = await _decrypt(row.symptomsJson);
    if ((row.diaryText.isNotEmpty && !_isProtected(row.diaryText)) ||
        (row.symptomsJson.isNotEmpty && !_isProtected(row.symptomsJson))) {
      await (_db.update(
        _db.localCycleDayLogs,
      )..where((table) => table.logDate.equals(row.logDate))).write(
        LocalCycleDayLogsCompanion(
          diaryText: row.diaryText.isNotEmpty && !_isProtected(row.diaryText)
              ? Value(await _encrypt(row.diaryText))
              : const Value.absent(),
          symptomsJson:
              row.symptomsJson.isNotEmpty && !_isProtected(row.symptomsJson)
              ? Value(await _encrypt(row.symptomsJson))
              : const Value.absent(),
          updatedAt: Value(DateTime.now()),
        ),
      );
    }
    return _CycleLogContent(
      flowLevel: row.flowLevel,
      diaryText: diary,
      symptomsJson: symptomsJson,
    );
  }

  Future<String> _encrypt(String value) async =>
      _cipher == null ? value : _cipher.encrypt(value);

  Future<String> _decrypt(String value) async =>
      _cipher == null ? value : _cipher.decrypt(value);

  bool _isProtected(String value) => _cipher?.isProtected(value) ?? true;

  void _validateDraft(CycleProfileDraft draft) {
    if (draft.periodLengthDays < 1 || draft.periodLengthDays > 15) {
      throw ArgumentError('经期天数请填写 1–15 天');
    }
    if (draft.cycleLengthDays < 15 ||
        draft.cycleLengthDays > 90 ||
        draft.cycleLengthDays <= draft.periodLengthDays) {
      throw ArgumentError('周期请填写 15–90 天，且长于经期天数');
    }
    final today = cycleDateOnly(DateTime.now());
    if (cycleDateOnly(draft.lastPeriodStartDate).isAfter(today)) {
      throw ArgumentError('最近一次经期开始不能晚于今天');
    }
    if (draft.birthDate != null &&
        cycleDateOnly(draft.birthDate!).isAfter(today)) {
      throw ArgumentError('生日不能晚于今天');
    }
  }
}

class _CycleLogContent {
  const _CycleLogContent({
    required this.flowLevel,
    required this.diaryText,
    required this.symptomsJson,
  });

  final String flowLevel;
  final String diaryText;
  final String symptomsJson;
}

DateTime cycleDateOnly(DateTime date) =>
    DateTime(date.year, date.month, date.day);
int cycleDaysBetween(DateTime a, DateTime b) => DateTime.utc(
  a.year,
  a.month,
  a.day,
).difference(DateTime.utc(b.year, b.month, b.day)).inDays;
String cycleDateKey(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

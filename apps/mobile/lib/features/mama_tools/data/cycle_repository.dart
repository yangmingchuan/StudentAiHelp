import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:little_hero/core/database/local_database.dart';
import 'package:little_hero/core/sync/operation_id_factory.dart';
import 'package:little_hero/features/mama_tools/domain/cycle_models.dart';

final cycleRepositoryProvider = Provider<CycleRepository>((ref) {
  return CycleRepository(
    ref.watch(localDatabaseProvider),
    ref.watch(operationIdFactoryProvider),
  );
});

class CycleRepository {
  const CycleRepository(this._db, this._operationIdFactory);

  final LocalDatabase _db;
  final OperationIdFactory _operationIdFactory;

  Future<CycleSnapshot> load({
    required DateTime visibleMonth,
    required DateTime selectedDate,
  }) async {
    await _ensureProfileRow();
    final profileRow = await _profileRow();
    final profile = _profileFromRow(profileRow);
    final today = _dateOnly(DateTime.now());
    final normalizedMonth = DateTime(visibleMonth.year, visibleMonth.month);
    final normalizedSelected = _dateOnly(selectedDate);

    if (profile == null) {
      final selectedDay = CycleDayInfo(
        date: normalizedSelected,
        cycleDay: 0,
        phase: CyclePhase.setup,
        tags: const ['待设置'],
        fertilityProbability: 0,
        summary: '先填写最近经期、持续天数和生日，日历会开始预测。',
        advice: '经期预测仅用于生活提醒，不能作为医学、避孕或妊娠判断依据。',
        diaryText: '',
        hasDiary: false,
      );
      return CycleSnapshot(
        needsSetup: true,
        profile: null,
        today: today,
        visibleMonth: normalizedMonth,
        selectedDate: normalizedSelected,
        calendarDays: _calendarDays(
          visibleMonth: normalizedMonth,
          selectedDate: normalizedSelected,
          today: today,
          profile: null,
          logsByDate: const {},
        ),
        selectedDay: selectedDay,
        healthScore: 0,
        dailyAdvice: selectedDay.advice,
      );
    }

    final logs = await _logsAroundMonth(normalizedMonth);
    final logsByDate = {for (final log in logs) log.logDate: log};
    final selectedLog = logsByDate[_formatDate(normalizedSelected)];
    final selectedDay = _dayInfo(
      normalizedSelected,
      profile,
      selectedLog?.diaryText ?? '',
    );

    return CycleSnapshot(
      needsSetup: false,
      profile: profile,
      today: today,
      visibleMonth: normalizedMonth,
      selectedDate: normalizedSelected,
      calendarDays: _calendarDays(
        visibleMonth: normalizedMonth,
        selectedDate: normalizedSelected,
        today: today,
        profile: profile,
        logsByDate: logsByDate,
      ),
      selectedDay: selectedDay,
      healthScore: _healthScore(profile, logs),
      dailyAdvice: selectedDay.advice,
    );
  }

  Future<void> saveSetup(CycleProfileDraft draft) {
    return saveSettings(draft);
  }

  Future<void> saveSettings(CycleProfileDraft draft) async {
    _validateDraft(draft);
    final operationId = _operationIdFactory.create();
    await _db
        .into(_db.localCycleProfiles)
        .insertOnConflictUpdate(
          LocalCycleProfilesCompanion.insert(
            id: const Value(1),
            lastPeriodStartDate: Value(_formatDate(draft.lastPeriodStartDate)),
            periodLengthDays: Value(draft.periodLengthDays),
            cycleLengthDays: Value(draft.cycleLengthDays),
            birthDate: Value(_formatDate(draft.birthDate)),
            isSetupComplete: const Value(true),
            updatedAt: Value(DateTime.now()),
          ),
        );
    await _enqueueOperation(
      operationId: operationId,
      operationType: 'cycle_profile_upsert',
      entityId: '1',
      payload: {
        'lastPeriodStartDate': _formatDate(draft.lastPeriodStartDate),
        'periodLengthDays': draft.periodLengthDays,
        'cycleLengthDays': draft.cycleLengthDays,
        'birthDate': _formatDate(draft.birthDate),
      },
    );
  }

  Future<void> saveDiary({
    required DateTime date,
    required String diaryText,
  }) async {
    final operationId = _operationIdFactory.create();
    final normalized = _dateOnly(date);
    await _db
        .into(_db.localCycleDayLogs)
        .insertOnConflictUpdate(
          LocalCycleDayLogsCompanion.insert(
            logDate: _formatDate(normalized),
            diaryText: Value(diaryText.trim()),
            operationId: Value(operationId),
            isDirty: const Value(true),
            updatedAt: Value(DateTime.now()),
          ),
        );
    await _enqueueOperation(
      operationId: operationId,
      operationType: 'cycle_day_log_upsert',
      entityId: _formatDate(normalized),
      payload: {
        'logDate': _formatDate(normalized),
        'diaryText': diaryText.trim(),
      },
    );
  }

  Future<LocalCycleProfile> _profileRow() {
    return (_db.select(
      _db.localCycleProfiles,
    )..where((table) => table.id.equals(1))).getSingle();
  }

  Future<void> _ensureProfileRow() async {
    final existing = await (_db.select(
      _db.localCycleProfiles,
    )..where((table) => table.id.equals(1))).getSingleOrNull();
    if (existing != null) {
      return;
    }
    await _db
        .into(_db.localCycleProfiles)
        .insert(LocalCycleProfilesCompanion.insert(id: const Value(1)));
  }

  CycleProfileSummary? _profileFromRow(LocalCycleProfile row) {
    if (!row.isSetupComplete ||
        row.lastPeriodStartDate == null ||
        row.birthDate == null) {
      return null;
    }
    return CycleProfileSummary(
      lastPeriodStartDate: DateTime.parse(row.lastPeriodStartDate!),
      periodLengthDays: row.periodLengthDays,
      cycleLengthDays: row.cycleLengthDays,
      birthDate: DateTime.parse(row.birthDate!),
      cloudSyncEnabled: row.cloudSyncEnabled,
    );
  }

  Future<List<LocalCycleDayLog>> _logsAroundMonth(DateTime visibleMonth) {
    final start = DateTime(visibleMonth.year, visibleMonth.month - 1, 1);
    final end = DateTime(visibleMonth.year, visibleMonth.month + 2, 0);
    return (_db.select(_db.localCycleDayLogs)..where(
          (table) =>
              table.logDate.isBiggerOrEqualValue(_formatDate(start)) &
              table.logDate.isSmallerOrEqualValue(_formatDate(end)),
        ))
        .get();
  }

  List<CycleCalendarDay> _calendarDays({
    required DateTime visibleMonth,
    required DateTime selectedDate,
    required DateTime today,
    required CycleProfileSummary? profile,
    required Map<String, LocalCycleDayLog> logsByDate,
  }) {
    final first = DateTime(visibleMonth.year, visibleMonth.month);
    final gridStart = first.subtract(Duration(days: first.weekday % 7));
    return [
      for (var index = 0; index < 42; index += 1)
        () {
          final date = _dateOnly(gridStart.add(Duration(days: index)));
          final log = logsByDate[_formatDate(date)];
          final info = profile == null
              ? CycleDayInfo(
                  date: date,
                  cycleDay: 0,
                  phase: CyclePhase.setup,
                  tags: const [],
                  fertilityProbability: 0,
                  summary: '待设置',
                  advice: '完成妈妈工具设置后显示预测。',
                  diaryText: log?.diaryText ?? '',
                  hasDiary: (log?.diaryText.trim().isNotEmpty ?? false),
                )
              : _dayInfo(date, profile, log?.diaryText ?? '');
          return CycleCalendarDay(
            date: date,
            isInVisibleMonth: date.month == visibleMonth.month,
            isToday: _isSameDay(date, today),
            isSelected: _isSameDay(date, selectedDate),
            info: info,
          );
        }(),
    ];
  }

  CycleDayInfo _dayInfo(
    DateTime date,
    CycleProfileSummary profile,
    String diaryText,
  ) {
    final normalized = _dateOnly(date);
    final cycleDay = _cycleDay(normalized, profile);
    final ovulationDay = max(1, profile.cycleLengthDays - 14);
    final periodEnd = profile.periodLengthDays;
    final fertileStart = max(periodEnd + 1, ovulationDay - 5);
    final fertileEnd = min(profile.cycleLengthDays, ovulationDay + 1);

    final isActualPeriod =
        !normalized.isBefore(profile.lastPeriodStartDate) &&
        normalized.isBefore(
          profile.lastPeriodStartDate.add(
            Duration(days: profile.periodLengthDays),
          ),
        );
    final isPeriodWindow = cycleDay <= profile.periodLengthDays;
    final isOvulation = cycleDay == ovulationDay;
    final isFertile = cycleDay >= fertileStart && cycleDay <= fertileEnd;
    final isSlim =
        cycleDay > periodEnd &&
        cycleDay < fertileStart &&
        fertileStart > periodEnd;
    final isLuteal =
        cycleDay > fertileEnd && cycleDay <= profile.cycleLengthDays;

    final phase = isActualPeriod
        ? CyclePhase.menstrual
        : isPeriodWindow
        ? CyclePhase.predictedPeriod
        : isOvulation
        ? CyclePhase.ovulation
        : isFertile
        ? CyclePhase.fertile
        : isSlim
        ? CyclePhase.slim
        : isLuteal
        ? CyclePhase.luteal
        : CyclePhase.normal;

    final tags = <String>{
      phase.label,
      if (isFertile && !isOvulation) '易孕日',
      if (isOvulation) '排卵期',
      if (isSlim) '易瘦期',
      if (isLuteal) '黄体期',
    }.toList();

    return CycleDayInfo(
      date: normalized,
      cycleDay: cycleDay,
      phase: phase,
      tags: tags,
      fertilityProbability: _fertilityProbability(
        cycleDay: cycleDay,
        ovulationDay: ovulationDay,
        fertileStart: fertileStart,
        fertileEnd: fertileEnd,
        isPeriodWindow: isPeriodWindow,
      ),
      summary: _summary(phase, cycleDay),
      advice: _advice(phase),
      diaryText: diaryText,
      hasDiary: diaryText.trim().isNotEmpty,
    );
  }

  int _cycleDay(DateTime date, CycleProfileSummary profile) {
    final diff = _dateOnly(
      date,
    ).difference(_dateOnly(profile.lastPeriodStartDate)).inDays;
    final cycle = profile.cycleLengthDays;
    return ((diff % cycle + cycle) % cycle) + 1;
  }

  double _fertilityProbability({
    required int cycleDay,
    required int ovulationDay,
    required int fertileStart,
    required int fertileEnd,
    required bool isPeriodWindow,
  }) {
    if (isPeriodWindow) {
      return 0;
    }
    if (cycleDay == ovulationDay) {
      return 33;
    }
    if (cycleDay < fertileStart || cycleDay > fertileEnd) {
      return cycleDay > ovulationDay ? 3 : 6;
    }
    final distance = (cycleDay - ovulationDay).abs();
    return switch (distance) {
      1 => 26,
      2 => 18,
      3 => 12,
      4 => 8,
      _ => 5,
    };
  }

  String _summary(CyclePhase phase, int cycleDay) {
    return switch (phase) {
      CyclePhase.menstrual => '月经期第$cycleDay天',
      CyclePhase.predictedPeriod => '预测月经期第$cycleDay天',
      CyclePhase.ovulation => '排卵期，易孕概率较高',
      CyclePhase.fertile => '易孕日，请按自己的计划安排',
      CyclePhase.slim => '易瘦期，适合轻量规律运动',
      CyclePhase.luteal => '黄体期，注意睡眠和情绪波动',
      CyclePhase.normal => '平稳期，保持规律作息',
      CyclePhase.setup => '待设置',
    };
  }

  String _advice(CyclePhase phase) {
    return switch (phase) {
      CyclePhase.menstrual => '多喝温水，注意保暖和休息。若疼痛或出血异常，请咨询医生。',
      CyclePhase.predictedPeriod => '这天可能接近月经期，可以提前准备卫生用品并关注身体状态。',
      CyclePhase.ovulation => '今天接近排卵日，易孕概率较高。预测仅供生活提醒，不作为避孕依据。',
      CyclePhase.fertile => '处于易孕窗口，若有备孕或避孕计划，请使用更可靠的方法确认。',
      CyclePhase.slim => '身体状态通常较轻快，可以安排舒缓运动和规律饮食。',
      CyclePhase.luteal => '黄体期容易疲劳、浮肿或情绪波动，建议减少熬夜和高糖饮食。',
      CyclePhase.normal => '保持睡眠、饮水和适度活动，继续观察身体变化。',
      CyclePhase.setup => '完成基础设置后显示每日建议。',
    };
  }

  int _healthScore(CycleProfileSummary profile, List<LocalCycleDayLog> logs) {
    final lengthScore =
        profile.periodLengthDays >= 3 && profile.periodLengthDays <= 7
        ? 35
        : 25;
    final cycleScore =
        profile.cycleLengthDays >= 24 && profile.cycleLengthDays <= 35
        ? 35
        : 24;
    final diaryScore = min(
      30,
      logs.where((log) => log.diaryText.isNotEmpty).length * 6,
    );
    return (lengthScore + cycleScore + diaryScore).clamp(0, 100);
  }

  void _validateDraft(CycleProfileDraft draft) {
    if (draft.periodLengthDays < 2 || draft.periodLengthDays > 10) {
      throw ArgumentError('月经持续天数建议填写 2-10 天');
    }
    if (draft.cycleLengthDays < 21 || draft.cycleLengthDays > 45) {
      throw ArgumentError('月经周期长度建议填写 21-45 天');
    }
    final today = _dateOnly(DateTime.now());
    if (_dateOnly(draft.birthDate).isAfter(today)) {
      throw ArgumentError('生日不能晚于今天');
    }
  }

  Future<void> _enqueueOperation({
    required String operationId,
    required String operationType,
    required String entityId,
    required Map<String, Object?> payload,
  }) {
    return _db
        .into(_db.syncOperations)
        .insertOnConflictUpdate(
          SyncOperationsCompanion.insert(
            operationId: operationId,
            operationType: operationType,
            entityId: entityId,
            payloadJson: jsonEncode(payload),
          ),
        );
  }
}

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

String _formatDate(DateTime value) {
  final date = _dateOnly(value);
  return '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

class CycleProfileDraft {
  const CycleProfileDraft({
    required this.lastPeriodStartDate,
    required this.periodLengthDays,
    required this.cycleLengthDays,
    this.birthDate,
  });

  final DateTime lastPeriodStartDate;
  final int periodLengthDays;
  final int cycleLengthDays;
  final DateTime? birthDate;
}

class CycleProfileSummary {
  const CycleProfileSummary({
    required this.lastPeriodStartDate,
    required this.periodLengthDays,
    required this.cycleLengthDays,
    this.birthDate,
    required this.cloudSyncEnabled,
  });

  final DateTime lastPeriodStartDate;
  final int periodLengthDays;
  final int cycleLengthDays;
  final DateTime? birthDate;
  final bool cloudSyncEnabled;
}

class CycleSnapshot {
  const CycleSnapshot({
    required this.needsSetup,
    required this.profile,
    required this.today,
    required this.visibleMonth,
    required this.selectedDate,
    required this.calendarDays,
    required this.selectedDay,
    required this.dailyAdvice,
    this.records = const [],
  });

  final bool needsSetup;
  final CycleProfileSummary? profile;
  final DateTime today;
  final DateTime visibleMonth;
  final DateTime selectedDate;
  final List<CycleCalendarDay> calendarDays;
  final CycleDayInfo selectedDay;
  final String dailyAdvice;
  final List<CycleDayInfo> records;

  DateTime? get nextPeriodDate => profile == null
      ? null
      : DateTime(
          profile!.lastPeriodStartDate.year,
          profile!.lastPeriodStartDate.month,
          profile!.lastPeriodStartDate.day + profile!.cycleLengthDays,
        );
}

class CycleCalendarDay {
  const CycleCalendarDay({
    required this.date,
    required this.isInVisibleMonth,
    required this.isToday,
    required this.isSelected,
    required this.info,
  });

  final DateTime date;
  final bool isInVisibleMonth;
  final bool isToday;
  final bool isSelected;
  final CycleDayInfo info;
}

class CycleDayInfo {
  const CycleDayInfo({
    required this.date,
    required this.cycleDay,
    required this.phase,
    required this.tags,
    required this.summary,
    required this.advice,
    required this.diaryText,
    required this.hasDiary,
    this.flow = CycleFlow.unlogged,
    this.symptoms = const [],
  });

  final DateTime date;
  final int cycleDay;
  final CyclePhase phase;
  final List<String> tags;
  final String summary;
  final String advice;
  final String diaryText;
  final bool hasDiary;

  final CycleFlow flow;
  final List<String> symptoms;
  bool get hasRecord =>
      hasDiary || flow != CycleFlow.unlogged || symptoms.isNotEmpty;
}

enum CycleFlow {
  unlogged('none', '未填写'),
  noBleeding('no_bleeding', '无经血'),
  light('light', '少量'),
  medium('medium', '中等'),
  heavy('heavy', '较多');

  const CycleFlow(this.value, this.label);
  final String value;
  final String label;
  bool get isBleeding => this == light || this == medium || this == heavy;
  static CycleFlow parse(String value) =>
      values.firstWhere((flow) => flow.value == value, orElse: () => unlogged);
}

enum CyclePhase {
  setup,
  menstrual,
  predictedPeriod,
  fertile,
  ovulation,
  slim,
  luteal,
  normal,
}

extension CyclePhaseLabel on CyclePhase {
  String get label {
    return switch (this) {
      CyclePhase.setup => '待设置',
      CyclePhase.menstrual => '已记录经期',
      CyclePhase.predictedPeriod => '预测月经期',
      CyclePhase.fertile => '预测易孕期',
      CyclePhase.ovulation => '预计排卵日',
      CyclePhase.slim => '经后阶段',
      CyclePhase.luteal => '预计经前阶段',
      CyclePhase.normal => '日常记录',
    };
  }
}

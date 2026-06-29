class CycleProfileDraft {
  const CycleProfileDraft({
    required this.lastPeriodStartDate,
    required this.periodLengthDays,
    required this.cycleLengthDays,
    required this.birthDate,
  });

  final DateTime lastPeriodStartDate;
  final int periodLengthDays;
  final int cycleLengthDays;
  final DateTime birthDate;
}

class CycleProfileSummary {
  const CycleProfileSummary({
    required this.lastPeriodStartDate,
    required this.periodLengthDays,
    required this.cycleLengthDays,
    required this.birthDate,
    required this.cloudSyncEnabled,
  });

  final DateTime lastPeriodStartDate;
  final int periodLengthDays;
  final int cycleLengthDays;
  final DateTime birthDate;
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
    required this.healthScore,
    required this.dailyAdvice,
  });

  final bool needsSetup;
  final CycleProfileSummary? profile;
  final DateTime today;
  final DateTime visibleMonth;
  final DateTime selectedDate;
  final List<CycleCalendarDay> calendarDays;
  final CycleDayInfo selectedDay;
  final int healthScore;
  final String dailyAdvice;
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
    required this.fertilityProbability,
    required this.summary,
    required this.advice,
    required this.diaryText,
    required this.hasDiary,
  });

  final DateTime date;
  final int cycleDay;
  final CyclePhase phase;
  final List<String> tags;
  final double fertilityProbability;
  final String summary;
  final String advice;
  final String diaryText;
  final bool hasDiary;

  String get fertilityLabel => '${fertilityProbability.toStringAsFixed(1)}%';
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
      CyclePhase.menstrual => '月经期',
      CyclePhase.predictedPeriod => '预测月经期',
      CyclePhase.fertile => '易孕日',
      CyclePhase.ovulation => '排卵期',
      CyclePhase.slim => '易瘦期',
      CyclePhase.luteal => '黄体期',
      CyclePhase.normal => '平稳期',
    };
  }
}

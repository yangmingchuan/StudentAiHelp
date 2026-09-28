import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:little_hero/features/mama_tools/data/cycle_repository.dart';
import 'package:little_hero/features/mama_tools/domain/cycle_models.dart';

final cycleControllerProvider =
    AsyncNotifierProvider<CycleController, CycleSnapshot>(CycleController.new);

class CycleController extends AsyncNotifier<CycleSnapshot> {
  DateTime _selectedDate = DateTime.now();
  DateTime _visibleMonth = DateTime(DateTime.now().year, DateTime.now().month);
  int _loadVersion = 0;

  CycleRepository get _repository => ref.read(cycleRepositoryProvider);

  @override
  Future<CycleSnapshot> build() {
    ref.watch(cycleRepositoryProvider);
    return _repository.load(
      visibleMonth: _visibleMonth,
      selectedDate: _selectedDate,
    );
  }

  Future<void> selectDate(DateTime date) async {
    _selectedDate = DateTime(date.year, date.month, date.day);
    _visibleMonth = DateTime(date.year, date.month);
    await _reload();
  }

  Future<void> previousMonth() async {
    _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month - 1);
    _selectVisibleMonthDay();
    await _reload();
  }

  Future<void> nextMonth() async {
    _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1);
    _selectVisibleMonthDay();
    await _reload();
  }

  void _selectVisibleMonthDay() {
    final lastDay = DateTime(
      _visibleMonth.year,
      _visibleMonth.month + 1,
      0,
    ).day;
    _selectedDate = DateTime(
      _visibleMonth.year,
      _visibleMonth.month,
      _selectedDate.day.clamp(1, lastDay),
    );
  }

  Future<void> goToToday() => selectDate(DateTime.now());
  Future<void> refresh() => _reload();

  Future<void> _reload() async {
    final version = ++_loadVersion;
    final next = await AsyncValue.guard(build);
    if (ref.mounted && version == _loadVersion) state = next;
  }

  Future<void> saveRecord({
    required DateTime date,
    required CycleFlow flow,
    required List<String> symptoms,
    required String diaryText,
    bool startsPeriod = false,
  }) async {
    await _repository.saveRecord(
      date: date,
      flow: flow,
      symptoms: symptoms,
      diaryText: diaryText,
      startsPeriod: startsPeriod,
    );
    await selectDate(date);
  }

  Future<void> saveSetup(CycleProfileDraft draft) async {
    await _repository.saveSetup(draft);
    _selectedDate = cycleDateOnly(DateTime.now());
    _visibleMonth = DateTime(_selectedDate.year, _selectedDate.month);
    await _reload();
  }

  Future<void> saveSettings(CycleProfileDraft draft) async {
    await _repository.saveSettings(draft);
    await _reload();
  }

  Future<void> saveDiary({
    required DateTime date,
    required String diaryText,
  }) async {
    await _repository.saveDiary(date: date, diaryText: diaryText);
    _selectedDate = DateTime(date.year, date.month, date.day);
    _visibleMonth = DateTime(date.year, date.month);
    await _reload();
  }
}

final cycleDayProvider = FutureProvider.autoDispose
    .family<CycleDayInfo, DateTime>((ref, date) {
      return ref.watch(cycleRepositoryProvider).loadDay(date);
    });

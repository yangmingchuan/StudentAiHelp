import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:little_hero/features/mama_tools/data/cycle_repository.dart';
import 'package:little_hero/features/mama_tools/domain/cycle_models.dart';

final cycleControllerProvider =
    AsyncNotifierProvider<CycleController, CycleSnapshot>(CycleController.new);

class CycleController extends AsyncNotifier<CycleSnapshot> {
  DateTime _selectedDate = DateTime.now();
  DateTime _visibleMonth = DateTime(DateTime.now().year, DateTime.now().month);

  CycleRepository get _repository => ref.read(cycleRepositoryProvider);

  @override
  Future<CycleSnapshot> build() {
    return _repository.load(
      visibleMonth: _visibleMonth,
      selectedDate: _selectedDate,
    );
  }

  Future<void> selectDate(DateTime date) async {
    _selectedDate = DateTime(date.year, date.month, date.day);
    _visibleMonth = DateTime(date.year, date.month);
    state = await AsyncValue.guard(build);
  }

  Future<void> previousMonth() async {
    _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month - 1);
    state = await AsyncValue.guard(build);
  }

  Future<void> nextMonth() async {
    _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1);
    state = await AsyncValue.guard(build);
  }

  Future<void> saveSetup(CycleProfileDraft draft) async {
    await _repository.saveSetup(draft);
    _selectedDate = draft.lastPeriodStartDate;
    _visibleMonth = DateTime(
      draft.lastPeriodStartDate.year,
      draft.lastPeriodStartDate.month,
    );
    state = await AsyncValue.guard(build);
  }

  Future<void> saveSettings(CycleProfileDraft draft) async {
    await _repository.saveSettings(draft);
    state = await AsyncValue.guard(build);
  }

  Future<void> saveDiary({
    required DateTime date,
    required String diaryText,
  }) async {
    await _repository.saveDiary(date: date, diaryText: diaryText);
    _selectedDate = DateTime(date.year, date.month, date.day);
    _visibleMonth = DateTime(date.year, date.month);
    state = await AsyncValue.guard(build);
  }
}

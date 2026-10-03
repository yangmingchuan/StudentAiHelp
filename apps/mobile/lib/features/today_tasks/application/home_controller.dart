import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:little_hero/features/today_tasks/data/home_repository.dart';
import 'package:little_hero/features/today_tasks/domain/home_snapshot.dart';

final homeControllerProvider =
    AsyncNotifierProvider<HomeController, HomeSnapshot>(HomeController.new);

class HomeController extends AsyncNotifier<HomeSnapshot> {
  HomeRepository get _repository => ref.read(homeRepositoryProvider);

  @override
  Future<HomeSnapshot> build() {
    ref.watch(homeRepositoryProvider);
    return _repository.load();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repository.load());
  }

  Future<void> setTaskStatus(int taskId, TaskStatus status) async {
    final previous = state;
    state = await AsyncValue.guard(
      () => _repository.setTaskStatus(taskId: taskId, nextStatus: status),
    );
    if (state.hasError && previous.hasValue) {
      state = previous;
    }
  }

  Future<void> clearTaskStatus(int taskId) async {
    final previous = state;
    state = await AsyncValue.guard(
      () => _repository.setTaskStatus(
        taskId: taskId,
        nextStatus: TaskStatus.none,
      ),
    );
    if (state.hasError && previous.hasValue) {
      state = previous;
    }
  }

  Future<void> setTodayRestDay(bool isRestDay) async {
    final snapshot = await _repository.setTodayRestDay(isRestDay: isRestDay);
    state = AsyncData(snapshot);
  }

  Future<void> refreshLocal() async {
    state = await AsyncValue.guard(
      () => _repository.load(refreshRemote: false),
    );
  }

  Future<void> addTask(String name, {String? iconName}) async {
    final snapshot = await _repository.addTask(name: name, iconName: iconName);
    state = AsyncData(snapshot);
  }

  Future<void> updateTask(int taskId, String name, {String? iconName}) async {
    final snapshot = await _repository.updateTask(
      taskId: taskId,
      name: name,
      iconName: iconName,
    );
    state = AsyncData(snapshot);
  }

  Future<void> deleteTask(int taskId) async {
    state = await AsyncValue.guard(() => _repository.deleteTask(taskId));
  }

  Future<void> moveTask(int oldIndex, int newIndex) async {
    state = await AsyncValue.guard(
      () => _repository.moveTask(oldIndex, newIndex),
    );
  }
}

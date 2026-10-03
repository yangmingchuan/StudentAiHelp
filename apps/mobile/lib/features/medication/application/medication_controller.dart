import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:little_hero/features/medication/application/medication_reminder_notifications.dart';
import 'package:little_hero/features/medication/data/medication_repository.dart';
import 'package:little_hero/features/medication/domain/medication_models.dart';

final medicationControllerProvider =
    AsyncNotifierProvider<MedicationController, MedicationSnapshot>(
      MedicationController.new,
    );

class MedicationController extends AsyncNotifier<MedicationSnapshot> {
  MedicationRepository get _repository =>
      ref.read(medicationRepositoryProvider);
  MedicationReminderNotifications get _notifications =>
      ref.read(medicationReminderNotificationsProvider);

  @override
  Future<MedicationSnapshot> build() {
    ref.watch(medicationRepositoryProvider);
    return _repository.load();
  }

  Future<void> addMember(MedicationMemberDraft draft) async {
    await _repository.addMember(draft);
    state = await AsyncValue.guard(build);
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(build);
  }

  Future<void> addMedicine(MedicineDraft draft) async {
    await _repository.addMedicine(draft);
    state = await AsyncValue.guard(build);
  }

  Future<void> addLog(MedicationLogDraft draft) async {
    final reminder = await _repository.addLog(draft);
    if (reminder != null) await _notifications.schedule(reminder);
    state = await AsyncValue.guard(build);
  }

  Future<void> amendLog({
    required int originalLogId,
    required MedicationLogDraft draft,
  }) async {
    final result = await _repository.amendLog(
      originalLogId: originalLogId,
      draft: draft,
    );
    for (final reminderId in result.canceledReminderIds) {
      await _notifications.cancel(reminderId);
    }
    if (result.reminder != null) {
      await _notifications.schedule(result.reminder!);
    }
    state = await AsyncValue.guard(build);
  }

  Future<void> deleteLog(int logId) async {
    final canceledReminderIds = await _repository.deleteLog(logId);
    for (final reminderId in canceledReminderIds) {
      await _notifications.cancel(reminderId);
    }
    state = await AsyncValue.guard(build);
  }

  Future<void> resolveReminder({
    required int reminderId,
    required MedicationReminderStatus status,
  }) async {
    await _repository.resolveReminder(reminderId: reminderId, status: status);
    await _notifications.cancel(reminderId);
    state = await AsyncValue.guard(build);
  }
}

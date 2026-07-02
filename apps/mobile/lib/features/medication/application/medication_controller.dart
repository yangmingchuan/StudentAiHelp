import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:little_hero/features/medication/data/medication_repository.dart';
import 'package:little_hero/features/medication/domain/medication_models.dart';

final medicationControllerProvider =
    AsyncNotifierProvider<MedicationController, MedicationSnapshot>(
      MedicationController.new,
    );

class MedicationController extends AsyncNotifier<MedicationSnapshot> {
  MedicationRepository get _repository =>
      ref.read(medicationRepositoryProvider);

  @override
  Future<MedicationSnapshot> build() {
    return _repository.load();
  }

  Future<void> addMember(MedicationMemberDraft draft) async {
    await _repository.addMember(draft);
    state = await AsyncValue.guard(build);
  }

  Future<void> addMedicine(MedicineDraft draft) async {
    await _repository.addMedicine(draft);
    state = await AsyncValue.guard(build);
  }

  Future<void> addLog(MedicationLogDraft draft) async {
    await _repository.addLog(draft);
    state = await AsyncValue.guard(build);
  }
}

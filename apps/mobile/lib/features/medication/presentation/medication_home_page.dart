import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:little_hero/core/theme/app_theme.dart';
import 'package:little_hero/core/widgets/page_heading.dart';
import 'package:little_hero/features/medication/application/medication_controller.dart';
import 'package:little_hero/features/medication/domain/medication_models.dart';

enum _MedicationSection { medicines, logs, members }

class MedicationHomePage extends ConsumerStatefulWidget {
  const MedicationHomePage({super.key});

  @override
  ConsumerState<MedicationHomePage> createState() => _MedicationHomePageState();
}

class _MedicationHomePageState extends ConsumerState<MedicationHomePage> {
  _MedicationSection _section = _MedicationSection.medicines;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(medicationControllerProvider);

    return state.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _MedicationErrorView(
        message: error.toString(),
        onRetry: () => ref.invalidate(medicationControllerProvider),
      ),
      data: (snapshot) {
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
          children: [
            const PageHeading(title: '家庭药箱', subtitle: '文字记录家庭成员、药品档案和每次用药'),
            const SizedBox(height: 16),
            const _SafetyNotice(),
            const SizedBox(height: 14),
            _MedicationSummary(snapshot: snapshot),
            if (_shouldShowAlerts(snapshot)) ...[
              const SizedBox(height: 14),
              _MedicationAlertCard(snapshot: snapshot),
            ],
            const SizedBox(height: 18),
            _MedicationSegments(
              selected: _section,
              onChanged: (section) => setState(() => _section = section),
            ),
            const SizedBox(height: 16),
            switch (_section) {
              _MedicationSection.medicines => _MedicineSection(
                medicines: snapshot.medicines,
                onAdd: () => _showMedicineSheet(context),
              ),
              _MedicationSection.logs => _LogSection(
                logs: snapshot.logs,
                onAdd: () => _showLogSheet(context, snapshot),
              ),
              _MedicationSection.members => _MemberSection(
                members: snapshot.members,
                onAdd: () => _showMemberSheet(context),
              ),
            },
          ],
        );
      },
    );
  }

  bool _shouldShowAlerts(MedicationSnapshot snapshot) {
    return snapshot.expiredCount > 0 ||
        snapshot.expiringSoonCount > 0 ||
        snapshot.upcomingReminders.isNotEmpty;
  }

  Future<void> _showMemberSheet(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return _MemberForm(
          onSubmit: (draft) async {
            await ref
                .read(medicationControllerProvider.notifier)
                .addMember(draft);
          },
        );
      },
    );
  }

  Future<void> _showMedicineSheet(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return _MedicineForm(
          onSubmit: (draft) async {
            await ref
                .read(medicationControllerProvider.notifier)
                .addMedicine(draft);
          },
        );
      },
    );
  }

  Future<void> _showLogSheet(
    BuildContext context,
    MedicationSnapshot snapshot,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return _LogForm(
          snapshot: snapshot,
          onSubmit: (draft) async {
            await ref.read(medicationControllerProvider.notifier).addLog(draft);
          },
        );
      },
    );
  }
}

class _SafetyNotice extends StatelessWidget {
  const _SafetyNotice();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.blue.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Padding(
        padding: EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_rounded, color: AppColors.blue),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                '这里只记录事实，不提供诊断、处方或剂量建议；用药请以医生和药品说明书为准。',
                style: TextStyle(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w700,
                  height: 1.45,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MedicationSummary extends StatelessWidget {
  const _MedicationSummary({required this.snapshot});

  final MedicationSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            label: '药品',
            value: snapshot.medicines.length.toString(),
            color: AppColors.green,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryCard(
            label: '今日记录',
            value: snapshot.todayLogCount.toString(),
            color: AppColors.orange,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryCard(
            label: '临期',
            value: (snapshot.expiredCount + snapshot.expiringSoonCount)
                .toString(),
            color: AppColors.coral,
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: TextStyle(
                  color: AppColors.ink.withValues(alpha: 0.68),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MedicationAlertCard extends StatelessWidget {
  const _MedicationAlertCard({required this.snapshot});

  final MedicationSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final alerts = [
      if (snapshot.expiredCount > 0) '有 ${snapshot.expiredCount} 个药品已过期',
      if (snapshot.expiringSoonCount > 0)
        '有 ${snapshot.expiringSoonCount} 个药品 30 天内到期',
      for (final reminder in snapshot.upcomingReminders)
        '${_formatDateTime(reminder.remindAt)} ${reminder.memberName} ${reminder.medicineName}',
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.notifications_active_rounded,
                  color: AppColors.coral,
                ),
                const SizedBox(width: 8),
                Text(
                  '提醒',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontSize: 20),
                ),
              ],
            ),
            const SizedBox(height: 10),
            for (final alert in alerts)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '•',
                      style: TextStyle(
                        color: AppColors.coral,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        alert,
                        style: const TextStyle(
                          color: AppColors.ink,
                          fontWeight: FontWeight.w700,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MedicationSegments extends StatelessWidget {
  const _MedicationSegments({required this.selected, required this.onChanged});

  final _MedicationSection selected;
  final ValueChanged<_MedicationSection> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<_MedicationSection>(
        selected: {selected},
        onSelectionChanged: (value) => onChanged(value.first),
        segments: const [
          ButtonSegment(
            value: _MedicationSection.medicines,
            icon: Icon(Icons.medication_liquid_rounded),
            label: Text('药品'),
          ),
          ButtonSegment(
            value: _MedicationSection.logs,
            icon: Icon(Icons.edit_note_rounded),
            label: Text('记录'),
          ),
          ButtonSegment(
            value: _MedicationSection.members,
            icon: Icon(Icons.groups_rounded),
            label: Text('成员'),
          ),
        ],
      ),
    );
  }
}

class _MedicineSection extends StatelessWidget {
  const _MedicineSection({required this.medicines, required this.onAdd});

  final List<MedicineItem> medicines;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SectionHeader(
          title: '家庭药品',
          actionLabel: '添加药品',
          icon: Icons.add_rounded,
          onAction: onAdd,
        ),
        const SizedBox(height: 12),
        if (medicines.isEmpty)
          _EmptyCard(
            icon: Icons.medication_rounded,
            title: '先添加常备药',
            subtitle: '药名、规格、有效期和存放位置都可以手动输入。',
            actionLabel: '添加药品',
            onAction: onAdd,
          )
        else
          for (final medicine in medicines) ...[
            _MedicineCard(medicine: medicine),
            const SizedBox(height: 12),
          ],
      ],
    );
  }
}

class _MedicineCard extends StatelessWidget {
  const _MedicineCard({required this.medicine});

  final MedicineItem medicine;

  @override
  Widget build(BuildContext context) {
    final expiry = _expiryLabel(medicine);
    final expiryColor = _expiryColor(medicine.expiryStatus);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.green.withValues(alpha: 0.14),
                  child: const Icon(
                    Icons.medication_liquid_rounded,
                    color: AppColors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medicine.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      if (medicine.specification.isNotEmpty)
                        Text(
                          medicine.specification,
                          style: TextStyle(
                            color: AppColors.ink.withValues(alpha: 0.62),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (medicine.defaultDosage.isNotEmpty)
                  _InfoChip(
                    icon: Icons.straighten_rounded,
                    label: medicine.defaultDosage,
                    color: AppColors.orange,
                  ),
                if (medicine.storageLocation.isNotEmpty)
                  _InfoChip(
                    icon: Icons.inventory_2_rounded,
                    label: medicine.storageLocation,
                    color: AppColors.blue,
                  ),
                _InfoChip(
                  icon: Icons.event_available_rounded,
                  label: expiry,
                  color: expiryColor,
                ),
                if (medicine.stockNote.isNotEmpty)
                  _InfoChip(
                    icon: Icons.shopping_bag_rounded,
                    label: medicine.stockNote,
                    color: AppColors.coral,
                  ),
              ],
            ),
            if (medicine.usageNote.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                medicine.usageNote,
                style: TextStyle(
                  color: AppColors.ink.withValues(alpha: 0.72),
                  fontWeight: FontWeight.w600,
                  height: 1.45,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LogSection extends StatelessWidget {
  const _LogSection({required this.logs, required this.onAdd});

  final List<MedicationLogEntry> logs;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SectionHeader(
          title: '用药记录',
          actionLabel: '记录用药',
          icon: Icons.add_rounded,
          onAction: onAdd,
        ),
        const SizedBox(height: 12),
        if (logs.isEmpty)
          _EmptyCard(
            icon: Icons.edit_note_rounded,
            title: '还没有用药记录',
            subtitle: '每次记录谁吃了什么、剂量、原因和下次提醒。',
            actionLabel: '记录用药',
            onAction: onAdd,
          )
        else
          for (final log in logs) ...[
            _LogCard(log: log),
            const SizedBox(height: 12),
          ],
      ],
    );
  }
}

class _LogCard extends StatelessWidget {
  const _LogCard({required this.log});

  final MedicationLogEntry log;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 10,
        ),
        leading: CircleAvatar(
          backgroundColor: AppColors.orange.withValues(alpha: 0.14),
          child: const Icon(
            Icons.edit_calendar_rounded,
            color: AppColors.orange,
          ),
        ),
        title: Text(
          '${log.memberName} · ${log.medicineName}',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_formatDateTime(log.takenAt)),
              if (log.dosageText.isNotEmpty) Text('剂量：${log.dosageText}'),
              if (log.reason.isNotEmpty) Text('原因：${log.reason}'),
              if (log.note.isNotEmpty) Text('备注：${log.note}'),
              if (log.nextReminderAt != null)
                Text('下次提醒：${_formatDateTime(log.nextReminderAt!)}'),
            ],
          ),
        ),
      ),
    );
  }
}

class _MemberSection extends StatelessWidget {
  const _MemberSection({required this.members, required this.onAdd});

  final List<MedicationMember> members;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SectionHeader(
          title: '家庭成员',
          actionLabel: '添加成员',
          icon: Icons.add_rounded,
          onAction: onAdd,
        ),
        const SizedBox(height: 12),
        if (members.isEmpty)
          _EmptyCard(
            icon: Icons.groups_rounded,
            title: '先建立家庭成员档案',
            subtitle: '年龄、过敏史和慢病备注会在记录用药时一起参考。',
            actionLabel: '添加成员',
            onAction: onAdd,
          )
        else
          for (final member in members) ...[
            _MemberCard(member: member),
            const SizedBox(height: 12),
          ],
      ],
    );
  }
}

class _MemberCard extends StatelessWidget {
  const _MemberCard({required this.member});

  final MedicationMember member;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: AppColors.blue.withValues(alpha: 0.14),
              child: const Icon(Icons.person_rounded, color: AppColors.blue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    member.subtitle,
                    style: TextStyle(
                      color: AppColors.ink.withValues(alpha: 0.62),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (member.allergyNote.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _InlineNote(
                      icon: Icons.warning_amber_rounded,
                      text: '过敏：${member.allergyNote}',
                      color: AppColors.coral,
                    ),
                  ],
                  if (member.conditionNote.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    _InlineNote(
                      icon: Icons.monitor_heart_rounded,
                      text: member.conditionNote,
                      color: AppColors.green,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.icon,
    required this.onAction,
  });

  final String title;
  final String actionLabel;
  final IconData icon;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        FilledButton.icon(
          onPressed: onAction,
          icon: Icon(icon),
          label: Text(actionLabel),
        ),
      ],
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.orange.withValues(alpha: 0.14),
              child: Icon(icon, color: AppColors.orange, size: 30),
            ),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.ink.withValues(alpha: 0.66),
                fontWeight: FontWeight.w600,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add_rounded),
              label: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, color: color, size: 18),
      label: Text(label),
      backgroundColor: color.withValues(alpha: 0.12),
      side: BorderSide.none,
      labelStyle: const TextStyle(fontWeight: FontWeight.w800),
    );
  }
}

class _InlineNote extends StatelessWidget {
  const _InlineNote({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: AppColors.ink.withValues(alpha: 0.72),
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

class _MemberForm extends StatefulWidget {
  const _MemberForm({required this.onSubmit});

  final Future<void> Function(MedicationMemberDraft draft) onSubmit;

  @override
  State<_MemberForm> createState() => _MemberFormState();
}

class _MemberFormState extends State<_MemberForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _relationController = TextEditingController(text: '家庭成员');
  final _ageController = TextEditingController();
  final _allergyController = TextEditingController();
  final _conditionController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _relationController.dispose();
    _ageController.dispose();
    _allergyController.dispose();
    _conditionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isSaving = true);
    try {
      await widget.onSubmit(
        MedicationMemberDraft(
          name: _nameController.text,
          relation: _relationController.text,
          ageNote: _ageController.text,
          allergyNote: _allergyController.text,
          conditionNote: _conditionController.text,
        ),
      );
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _BottomSheetScaffold(
      title: '添加家庭成员',
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _TextInput(
              controller: _nameController,
              label: '姓名',
              icon: Icons.person_rounded,
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            _TextInput(
              controller: _relationController,
              label: '关系',
              icon: Icons.badge_rounded,
            ),
            const SizedBox(height: 12),
            _TextInput(
              controller: _ageController,
              label: '年龄备注',
              hintText: '例如 6 岁、老人、成人',
              icon: Icons.cake_rounded,
            ),
            const SizedBox(height: 12),
            _TextInput(
              controller: _allergyController,
              label: '过敏史',
              hintText: '没有可留空',
              icon: Icons.warning_amber_rounded,
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            _TextInput(
              controller: _conditionController,
              label: '慢病/禁忌备注',
              hintText: '例如 哮喘、胃病、正在服用某药',
              icon: Icons.monitor_heart_rounded,
              maxLines: 2,
            ),
            const SizedBox(height: 18),
            _SaveButton(isSaving: _isSaving, onPressed: _save),
          ],
        ),
      ),
    );
  }
}

class _MedicineForm extends StatefulWidget {
  const _MedicineForm({required this.onSubmit});

  final Future<void> Function(MedicineDraft draft) onSubmit;

  @override
  State<_MedicineForm> createState() => _MedicineFormState();
}

class _MedicineFormState extends State<_MedicineForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _specController = TextEditingController();
  final _dosageController = TextEditingController();
  final _storageController = TextEditingController();
  final _stockController = TextEditingController();
  final _usageController = TextEditingController();
  DateTime? _expiresOn;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _specController.dispose();
    _dosageController.dispose();
    _storageController.dispose();
    _stockController.dispose();
    _usageController.dispose();
    super.dispose();
  }

  Future<void> _pickExpiryDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiresOn ?? DateTime(now.year + 1, now.month, now.day),
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null) {
      setState(() => _expiresOn = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isSaving = true);
    try {
      await widget.onSubmit(
        MedicineDraft(
          name: _nameController.text,
          specification: _specController.text,
          defaultDosage: _dosageController.text,
          storageLocation: _storageController.text,
          expiresOn: _expiresOn,
          stockNote: _stockController.text,
          usageNote: _usageController.text,
        ),
      );
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _BottomSheetScaffold(
      title: '添加药品',
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _TextInput(
              controller: _nameController,
              label: '药品名称',
              icon: Icons.medication_rounded,
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            _TextInput(
              controller: _specController,
              label: '规格',
              hintText: '例如 100ml、0.25g*12片',
              icon: Icons.inventory_2_rounded,
            ),
            const SizedBox(height: 12),
            _TextInput(
              controller: _dosageController,
              label: '常用剂量备注',
              hintText: '只记录包装或医生说明，不自动建议剂量',
              icon: Icons.straighten_rounded,
            ),
            const SizedBox(height: 12),
            _TextInput(
              controller: _storageController,
              label: '存放位置',
              hintText: '例如 客厅药箱、冰箱',
              icon: Icons.home_rounded,
            ),
            const SizedBox(height: 12),
            _PickerField(
              icon: Icons.event_available_rounded,
              label: '有效期',
              value: _expiresOn == null ? '未填写' : _formatDate(_expiresOn!),
              onTap: _pickExpiryDate,
              onClear: _expiresOn == null
                  ? null
                  : () => setState(() => _expiresOn = null),
            ),
            const SizedBox(height: 12),
            _TextInput(
              controller: _stockController,
              label: '库存备注',
              hintText: '例如 剩半瓶、剩 8 片',
              icon: Icons.shopping_bag_rounded,
            ),
            const SizedBox(height: 12),
            _TextInput(
              controller: _usageController,
              label: '用途/注意事项',
              hintText: '例如 发热备用；开封后注意日期',
              icon: Icons.notes_rounded,
              maxLines: 3,
            ),
            const SizedBox(height: 18),
            _SaveButton(isSaving: _isSaving, onPressed: _save),
          ],
        ),
      ),
    );
  }
}

class _LogForm extends StatefulWidget {
  const _LogForm({required this.snapshot, required this.onSubmit});

  final MedicationSnapshot snapshot;
  final Future<void> Function(MedicationLogDraft draft) onSubmit;

  @override
  State<_LogForm> createState() => _LogFormState();
}

class _LogFormState extends State<_LogForm> {
  final _formKey = GlobalKey<FormState>();
  final _memberController = TextEditingController();
  final _medicineController = TextEditingController();
  final _dosageController = TextEditingController();
  final _reasonController = TextEditingController();
  final _noteController = TextEditingController();
  int? _memberId;
  int? _medicineId;
  DateTime _takenAt = DateTime.now();
  DateTime? _nextReminderAt;
  bool _isSaving = false;

  @override
  void dispose() {
    _memberController.dispose();
    _medicineController.dispose();
    _dosageController.dispose();
    _reasonController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickTakenAt() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _takenAt,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (pickedDate == null || !mounted) {
      return;
    }
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_takenAt),
    );
    if (pickedTime == null) {
      return;
    }
    setState(() {
      _takenAt = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  Future<void> _pickReminderAt() async {
    final initial =
        _nextReminderAt ?? DateTime.now().add(const Duration(hours: 6));
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate == null || !mounted) {
      return;
    }
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (pickedTime == null) {
      return;
    }
    setState(() {
      _nextReminderAt = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  void _selectMember(int? id) {
    final member = widget.snapshot.members
        .where((item) => item.id == id)
        .firstOrNull;
    setState(() {
      _memberId = id;
      if (member != null) {
        _memberController.text = member.name;
      }
    });
  }

  void _selectMedicine(int? id) {
    final medicine = widget.snapshot.medicines
        .where((item) => item.id == id)
        .firstOrNull;
    setState(() {
      _medicineId = id;
      if (medicine != null) {
        _medicineController.text = medicine.name;
        if (_dosageController.text.trim().isEmpty) {
          _dosageController.text = medicine.defaultDosage;
        }
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isSaving = true);
    try {
      await widget.onSubmit(
        MedicationLogDraft(
          memberId: _memberId,
          medicineId: _medicineId,
          memberName: _memberController.text,
          medicineName: _medicineController.text,
          takenAt: _takenAt,
          dosageText: _dosageController.text,
          reason: _reasonController.text,
          note: _noteController.text,
          nextReminderAt: _nextReminderAt,
        ),
      );
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _BottomSheetScaffold(
      title: '记录用药',
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            if (widget.snapshot.members.isNotEmpty) ...[
              _DropdownField<int?>(
                label: '选择成员',
                icon: Icons.person_rounded,
                value: _memberId,
                items: [
                  const DropdownMenuItem(value: null, child: Text('手动输入')),
                  for (final member in widget.snapshot.members)
                    DropdownMenuItem(
                      value: member.id,
                      child: Text(member.name),
                    ),
                ],
                onChanged: _selectMember,
              ),
              const SizedBox(height: 12),
            ],
            _TextInput(
              controller: _memberController,
              label: '用药成员',
              icon: Icons.groups_rounded,
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            if (widget.snapshot.medicines.isNotEmpty) ...[
              _DropdownField<int?>(
                label: '选择药品',
                icon: Icons.medication_rounded,
                value: _medicineId,
                items: [
                  const DropdownMenuItem(value: null, child: Text('手动输入')),
                  for (final medicine in widget.snapshot.medicines)
                    DropdownMenuItem(
                      value: medicine.id,
                      child: Text(medicine.name),
                    ),
                ],
                onChanged: _selectMedicine,
              ),
              const SizedBox(height: 12),
            ],
            _TextInput(
              controller: _medicineController,
              label: '药品名称',
              icon: Icons.medication_liquid_rounded,
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            _TextInput(
              controller: _dosageController,
              label: '本次剂量',
              hintText: '例如 5ml、1片',
              icon: Icons.straighten_rounded,
            ),
            const SizedBox(height: 12),
            _PickerField(
              icon: Icons.schedule_rounded,
              label: '用药时间',
              value: _formatDateTime(_takenAt),
              onTap: _pickTakenAt,
            ),
            const SizedBox(height: 12),
            _TextInput(
              controller: _reasonController,
              label: '用药原因',
              hintText: '例如 发烧、咳嗽、过敏',
              icon: Icons.sick_rounded,
            ),
            const SizedBox(height: 12),
            _TextInput(
              controller: _noteController,
              label: '备注',
              hintText: '例如 饭后服用、体温 38.2',
              icon: Icons.notes_rounded,
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            _PickerField(
              icon: Icons.notifications_active_rounded,
              label: '下次提醒',
              value: _nextReminderAt == null
                  ? '不设置'
                  : _formatDateTime(_nextReminderAt!),
              onTap: _pickReminderAt,
              onClear: _nextReminderAt == null
                  ? null
                  : () => setState(() => _nextReminderAt = null),
            ),
            const SizedBox(height: 18),
            _SaveButton(isSaving: _isSaving, onPressed: _save),
          ],
        ),
      ),
    );
  }
}

class _BottomSheetScaffold extends StatelessWidget {
  const _BottomSheetScaffold({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 18,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    tooltip: '关闭',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _TextInput extends StatelessWidget {
  const _TextInput({
    required this.controller,
    required this.label,
    required this.icon,
    this.hintText,
    this.maxLines = 1,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? hintText;
  final int maxLines;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }
}

class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    this.onClear,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.ink.withValues(alpha: 0.24)),
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        leading: Icon(icon),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(value),
        trailing: onClear == null
            ? const Icon(Icons.chevron_right_rounded)
            : IconButton(
                tooltip: '清除',
                onPressed: onClear,
                icon: const Icon(Icons.close_rounded),
              ),
        onTap: onTap,
      ),
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.icon,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final IconData icon;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      items: items,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.isSaving, required this.onPressed});

  final bool isSaving;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: isSaving ? null : onPressed,
        child: Text(isSaving ? '保存中...' : '保存'),
      ),
    );
  }
}

class _MedicationErrorView extends StatelessWidget {
  const _MedicationErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, color: AppColors.coral),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('重试')),
          ],
        ),
      ),
    );
  }
}

String? _requiredValidator(String? value) {
  if (value == null || value.trim().isEmpty) {
    return '请填写';
  }
  return null;
}

String _expiryLabel(MedicineItem medicine) {
  final expiresOn = medicine.expiresOn;
  if (expiresOn == null) {
    return '未填有效期';
  }
  final dateLabel = _formatDate(expiresOn);
  return switch (medicine.expiryStatus) {
    MedicineExpiryStatus.expired => '$dateLabel 已过期',
    MedicineExpiryStatus.expiringSoon => '$dateLabel 临期',
    MedicineExpiryStatus.ok => '$dateLabel 到期',
    MedicineExpiryStatus.unknown => '未填有效期',
  };
}

Color _expiryColor(MedicineExpiryStatus status) {
  return switch (status) {
    MedicineExpiryStatus.expired => AppColors.coral,
    MedicineExpiryStatus.expiringSoon => AppColors.orange,
    MedicineExpiryStatus.ok => AppColors.green,
    MedicineExpiryStatus.unknown => AppColors.blue,
  };
}

String _formatDate(DateTime date) {
  return '${date.year}年${date.month}月${date.day}日';
}

String _formatDateTime(DateTime date) {
  return '${_formatDate(date)} ${date.hour.toString().padLeft(2, '0')}:'
      '${date.minute.toString().padLeft(2, '0')}';
}

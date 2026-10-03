import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:little_hero/core/theme/app_theme.dart';
import 'package:little_hero/core/widgets/page_heading.dart';
import 'package:little_hero/features/today_tasks/application/home_controller.dart';
import 'package:little_hero/features/today_tasks/domain/home_snapshot.dart';
import 'package:little_hero/features/todos/domain/task_templates.dart';

class TodoManagementPage extends ConsumerWidget {
  const TodoManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo 管理'),
        leading: BackButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/profile');
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: '新增 Todo',
        onPressed: () => _showTodoDialog(context, ref),
        child: const Icon(Icons.add_rounded),
      ),
      body: SafeArea(
        child: state.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _ErrorView(message: error.toString()),
          data: (snapshot) => _TodoList(tasks: snapshot.tasks),
        ),
      ),
    );
  }
}

class _TodoList extends ConsumerWidget {
  const _TodoList({required this.tasks});

  final List<TaskSummary> tasks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (tasks.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 96),
        children: const [
          PageHeading(title: 'Todo', subtitle: '先添加一个首页任务'),
          SizedBox(height: 24),
          _EmptyTodos(),
        ],
      );
    }

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 22, 20, 18),
          child: PageHeading(title: 'Todo', subtitle: '管理首页展示的任务'),
        ),
        Expanded(
          child: ReorderableListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 96),
            buildDefaultDragHandles: false,
            itemCount: tasks.length,
            onReorderItem: (oldIndex, newIndex) {
              ref
                  .read(homeControllerProvider.notifier)
                  .moveTask(oldIndex, newIndex);
            },
            itemBuilder: (context, index) {
              final task = tasks[index];
              return Padding(
                key: ValueKey(task.id),
                padding: const EdgeInsets.only(bottom: 12),
                child: _TodoTile(task: task, index: index),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _TodoTile extends ConsumerWidget {
  const _TodoTile({required this.task, required this.index});

  final TaskSummary task;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textStyle = Theme.of(
      context,
    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w400);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 6, 8),
        child: Row(
          children: [
            ReorderableDragStartListener(
              index: index,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Icon(Icons.drag_indicator_rounded),
              ),
            ),
            const SizedBox(width: 6),
            if (templateForTask(task.name, task.iconName)
                case final template?) ...[
              Image.asset(template.asset, width: 40, height: 40),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                task.name,
                style: textStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              tooltip: '编辑',
              onPressed: () => _showTodoDialog(context, ref, task: task),
              icon: const Icon(Icons.edit_rounded),
            ),
            IconButton(
              tooltip: '删除',
              onPressed: () => _confirmDelete(context, ref, task),
              icon: const Icon(Icons.delete_outline_rounded),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyTodos extends StatelessWidget {
  const _EmptyTodos();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.checklist_rtl_rounded,
              size: 52,
              color: AppColors.blue.withValues(alpha: 0.9),
            ),
            const SizedBox(height: 12),
            Text('还没有首页任务', style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }
}

Future<void> _showTodoDialog(
  BuildContext context,
  WidgetRef ref, {
  TaskSummary? task,
}) async {
  final result = await showDialog<_TodoFormResult>(
    context: context,
    builder: (context) => _TodoFormDialog(
      initialTitle: task?.name ?? '',
      initialIcon: task?.iconName,
      isEditing: task != null,
    ),
  );

  if (result == null) {
    return;
  }
  await Future<void>.delayed(Duration.zero);
  if (!context.mounted) {
    return;
  }

  try {
    if (task == null) {
      await ref
          .read(homeControllerProvider.notifier)
          .addTask(result.title, iconName: result.iconName);
    } else {
      await ref
          .read(homeControllerProvider.notifier)
          .updateTask(task.id, result.title, iconName: result.iconName);
    }
  } catch (error) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(error.toString())));
  }
}

Future<void> _confirmDelete(
  BuildContext context,
  WidgetRef ref,
  TaskSummary task,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('删除任务？'),
      content: Text('删除后，${task.name} 的历史打卡记录仍会保留。'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('删除'),
        ),
      ],
    ),
  );

  if (confirmed != true) {
    return;
  }

  try {
    await ref.read(homeControllerProvider.notifier).deleteTask(task.id);
  } catch (error) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(error.toString())));
  }
}

class _TodoFormResult {
  const _TodoFormResult(this.title, this.iconName);

  final String title;
  final String? iconName;
}

class _TodoFormDialog extends StatefulWidget {
  const _TodoFormDialog({
    required this.initialTitle,
    required this.isEditing,
    this.initialIcon,
  });

  final String initialTitle;
  final bool isEditing;
  final String? initialIcon;

  @override
  State<_TodoFormDialog> createState() => _TodoFormDialogState();
}

class _TodoFormDialogState extends State<_TodoFormDialog> {
  late final TextEditingController _titleController;
  String? _iconName;
  String? _error;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _iconName = widget.initialIcon;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isEditing ? '编辑任务' : '新增任务'),
      content: SizedBox(
        width: 360,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * .5,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  autofocus: widget.isEditing,
                  maxLength: 14,
                  decoration: InputDecoration(
                    labelText: '任务名称',
                    errorText: _error,
                  ),
                ),
                const SizedBox(height: 12),
                const Text('选一个小任务，也可以自己填写'),
                for (final category in ['家务', '运动', '阅读']) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 8),
                    child: Text(category),
                  ),
                  Row(
                    children: [
                      for (final template in taskTemplates.where(
                        (item) => item.category == category,
                      ))
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: Semantics(
                              selected: _iconName == template.iconName,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 10,
                                  ),
                                  backgroundColor:
                                      _iconName == template.iconName
                                      ? Theme.of(
                                          context,
                                        ).colorScheme.primaryContainer
                                      : null,
                                ),
                                onPressed: () => setState(() {
                                  _titleController.text = template.name;
                                  _iconName = template.iconName;
                                  _error = null;
                                }),
                                child: Column(
                                  children: [
                                    Image.asset(
                                      template.asset,
                                      width: 48,
                                      height: 48,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      template.name,
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () {
            final name = _titleController.text.trim();
            final length = name.runes.fold<double>(
              0,
              (total, rune) => total + (rune <= 255 ? .5 : 1),
            );
            if (name.isEmpty || length > 7) {
              setState(() => _error = '请填写任务名称，最多 7 个汉字');
              return;
            }
            Navigator.pop(context, _TodoFormResult(name, _iconName));
          },
          child: const Text('保存'),
        ),
      ],
    );
  }
}

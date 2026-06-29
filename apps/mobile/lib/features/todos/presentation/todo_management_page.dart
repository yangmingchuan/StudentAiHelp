import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:little_hero/core/theme/app_theme.dart';
import 'package:little_hero/core/widgets/page_heading.dart';
import 'package:little_hero/features/today_tasks/application/home_controller.dart';
import 'package:little_hero/features/today_tasks/domain/home_snapshot.dart';

class TodoManagementPage extends ConsumerWidget {
  const TodoManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Todo 管理')),
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
    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800);

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
      await ref.read(homeControllerProvider.notifier).addTask(result.title);
    } else {
      await ref
          .read(homeControllerProvider.notifier)
          .updateTask(task.id, result.title);
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
  const _TodoFormResult(this.title);

  final String title;
}

class _TodoFormDialog extends StatefulWidget {
  const _TodoFormDialog({required this.initialTitle, required this.isEditing});

  final String initialTitle;
  final bool isEditing;

  @override
  State<_TodoFormDialog> createState() => _TodoFormDialogState();
}

class _TodoFormDialogState extends State<_TodoFormDialog> {
  late final TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
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
      content: TextField(
        controller: _titleController,
        autofocus: true,
        maxLength: 14,
        decoration: const InputDecoration(labelText: '任务名称'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.pop(context, _TodoFormResult(_titleController.text)),
          child: const Text('保存'),
        ),
      ],
    );
  }
}

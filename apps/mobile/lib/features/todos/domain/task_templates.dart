class TaskTemplate {
  const TaskTemplate(
    this.name,
    this.category,
    this.iconName,
    this.asset,
    this.hint,
  );
  final String name;
  final String category;
  final String iconName;
  final String asset;
  final String hint;
}

const taskTemplates = [
  TaskTemplate(
    '扫地',
    '家务',
    'task_sweep',
    'assets/task_icons/sweep.png',
    '扫一小块地，帮家里变干净',
  ),
  TaskTemplate(
    '擦桌子',
    '家务',
    'task_wipe_table',
    'assets/task_icons/wipe_table.png',
    '轻轻擦一擦，桌面真整洁',
  ),
  TaskTemplate(
    '跳绳',
    '运动',
    'task_jump_rope',
    'assets/task_icons/jump_rope.png',
    '找一块空地，按自己的节奏跳',
  ),
  TaskTemplate(
    '户外运动',
    '运动',
    'task_outdoor',
    'assets/task_icons/outdoor.png',
    '和家人一起，去户外动一动',
  ),
  TaskTemplate(
    '阅读绘本',
    '阅读',
    'task_read_book',
    'assets/task_icons/read_book.png',
    '翻开绘本，发现新的故事',
  ),
  TaskTemplate(
    '朗读故事',
    '阅读',
    'task_read_aloud',
    'assets/task_icons/read_aloud.png',
    '大声读一读，把故事分享出来',
  ),
];

TaskTemplate? templateForTask(String name, String iconName) {
  for (final template in taskTemplates) {
    if (template.iconName == iconName) return template;
  }
  final title = name.trim();
  for (final template in taskTemplates) {
    if (title.contains(template.name)) return template;
  }
  return null;
}

import 'package:age_sync/utils/task_repeat.dart';

import 'constants.dart';

class Task {
  Task({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.details,
    required this.deadline,
    required this.createdAt,
    required this.repeat,
    required this.completed,
  });

  final String id;
  final String ownerId;
  final String name;
  final String details;
  final DateTime deadline;
  final DateTime createdAt;
  final TaskRepeat repeat;
  bool completed;

  Task.fromMap(Map<String, dynamic> map)
      : id = map['id'] as String,
        ownerId = map['owner_id'] as String,
        name = map['name'] as String,
        details = map['details'] as String,
        deadline = DateTime.parse(map['deadline'] as String),
        createdAt = DateTime.parse(map['created_at'] as String),
        repeat = TaskRepeat.values
            .firstWhere((element) => element.name == map['repeat'] as String),
        completed = map['completed'] as bool;

  static Future<Task> fromId(String uuid) async {
    return Task.fromMap(
        await supabase.from('tasks').select().eq('id', uuid).single());
  }

  static Future<List<Task>> getTasks(String id) async {
    final List<dynamic> tasks = await supabase
        .from('tasks')
        .select()
        .order('deadline', ascending: true);

    return await Future.wait(
        tasks.map((map) => Task.fromId(map['id'] as String)));
  }

  toggleCompleted() async {
    completed = !completed;

    await supabase.rpc('update_task_completed', params: {
      'tid': id,
      'complete': completed,
    });
  }

  static Future<Task> createTask(
      {required String name,
      required String details,
      required DateTime deadline,
      required TaskRepeat repeat,
      String? assign}) async {
    final taskMap = {
      'owner_id': supabase.userId,
      'name': name,
      'details': details,
      'deadline': deadline.toIso8601String(),
      'repeat': repeat.name
    };

    final taskId =
        await supabase.from('tasks').insert(taskMap).select('id').single();

    if (assign != null) {
      await supabase.from('task_assignees').insert({
        'task_id': taskId['id'],
        'assignee_id': assign,
      });
    }

    return await Task.fromId(taskId['id'] as String);
  }
}

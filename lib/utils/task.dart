import 'constants.dart';

class Task {
  Task({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.details,
    required this.deadline,
    required this.completed,
  });

  final String id;
  final String ownerId;
  final String name;
  final String details;
  final DateTime deadline;
  bool completed;

  Task.fromMap(Map<String, dynamic> map)
      : id = map['id'] as String,
        ownerId = map['owner_id'] as String,
        name = map['name'] as String,
        details = map['details'] as String,
        deadline = DateTime.parse(map['deadline'] as String),
        completed = map['completed'] as bool;

  static Future<Task> fromId(String uuid) async {
    return Task.fromMap(
        await supabase.from('tasks').select().eq('id', uuid).single());
  }

  static Future<List<Task>> assignedFromProfileId(String uuid) async {
    final List<dynamic> tasks =
        await supabase.from('task_assignees').select().eq('assignee_id', uuid);

    return await Future.wait(
        tasks.map((map) => Task.fromId(map['task_id'] as String)));
  }

  static Future<List<Task>> createdFromProfileId(String uuid) async {
    final List<dynamic> tasks =
        await supabase.from('tasks').select().eq('owner_id', uuid);

    return await Future.wait(
        tasks.map((map) => Task.fromId(map['id'] as String)));
  }

  toggleCompleted() async {
    completed = !completed;

    await supabase.from('tasks').update({
      'completed': completed,
    }).eq('id', id);
  }
}

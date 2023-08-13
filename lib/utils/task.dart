import 'package:age_sync/utils/profile.dart';

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

  static Future<List<Task>> getTasks(Profile user) async {
    final List<dynamic> tasks =
        await supabase.from(user.elder ? 'tasks' : 'task_assignees').select();

    return await Future.wait(tasks.map((map) => Task.fromId(map[
            user.elder ? 'id' : 'task_id']
        as String))); // id vs task_id because tasks uses id, task_assignees uses task_id
  }

  toggleCompleted() async {
    completed = !completed;

    await supabase.from('tasks').update({
      'completed': completed,
    }).eq('id', id);
  }
}

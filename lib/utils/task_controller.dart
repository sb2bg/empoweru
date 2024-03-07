import 'dart:async';

import 'package:age_sync/utils/constants.dart';
import 'package:age_sync/utils/task.dart';

class TaskController {
  late Future<List<Task>> ready;
  final List<Task> _tasks = [];
  final List<StreamController> _controllers = [];

  TaskController() {
    loadTasks((tasks) {
      _tasks.addAll(tasks);
    });
  }

  void loadTasks(Function(List<Task>) callback) {
    ready = Task.getTasks(supabase.userId);
    ready.then(callback);
  }

  void addTask(Task task) {
    _tasks.add(task);
    callListeners();
  }

  void removeTask(Task task) {
    _tasks.remove(task);
    callListeners();
  }

  void toggleTask(Task task) {
    task.toggleCompleted();
    callListeners();
  }

  void callListeners() {
    for (final controller in _controllers) {
      controller.add(_tasks);
    }
  }

  StreamSubscription listen(Function(List<Task>) listener) {
    final stream = StreamController<List<Task>>();
    _controllers.add(stream);
    stream.add(_tasks);

    return stream.stream.listen(listener);
  }
}

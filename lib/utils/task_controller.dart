import 'package:age_sync/utils/constants.dart';
import 'package:age_sync/utils/task.dart';

class TaskController {
  late Future<List<Task>> future;
  final List<Task> tasks = [];
  final List<Function> listeners = [];

  TaskController() {
    loadTasks((tasks) {
      this.tasks.addAll(tasks);
    });
  }

  loadTasks(Function(List<Task>) callback) {
    future = Task.getTasks(supabase.userId);
    future.then(callback);
  }

  addTask(Task task) {
    tasks.add(task);
    callListeners();
  }

  removeTask(Task task) {
    tasks.remove(task);
    callListeners();
  }

  toggleTask(Task task) {
    task.toggleCompleted();
    callListeners();
  }

  callListeners() {
    for (final listener in listeners) {
      listener();
    }
  }

  addListener(Function listener) {
    listeners.add(listener);
  }

  reload() {
    loadTasks((tasks) {
      this.tasks.clear();
      this.tasks.addAll(tasks);

      callListeners();
    });
  }
}

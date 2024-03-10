import 'dart:async';

import 'package:age_sync/utils/constants.dart';
import 'package:age_sync/utils/task.dart';

import 'package:flutter/foundation.dart';

class TaskController extends ChangeNotifier {
  final List<Task> tasks = [];
  late final Future<void> ready;

  TaskController() {
    ready = loadTasks();
  }

  Future<void> loadTasks() async {
    tasks.addAll(await Task.getTasks(supabase.userId));
    notifyListeners();
  }

  void addTask(Task task) {
    tasks.add(task);
    notifyListeners();
  }

  void removeTask(Task task) {
    tasks.remove(task);
    notifyListeners();
  }

  void toggleTask(Task task) {
    task.toggleCompleted();
    notifyListeners();
  }
}

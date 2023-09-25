import 'package:age_sync/utils/loading_state.dart';
import 'package:age_sync/utils/task.dart';
import 'package:age_sync/widgets/task_view.dart';
import 'package:flutter/material.dart';

import '../../utils/constants.dart';
import 'new_task_page.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  static const routeName = '/task';

  @override
  State<TaskPage> createState() => _TaskPageState();
}

enum Filter {
  all,
  completed,
  incomplete,
}

class _TaskPageState extends LoadingState<TaskPage> {
  late List<Task> _tasks;
  late List<Task> _filteredTasks;
  late bool _elder;
  Filter _filter = Filter.all;

  @override
  Future<void> onInit() async {
    if (firstLoad) {
      taskController.addListener(() {
        if (!mounted) return; // Prevent setState() if not mounted

        setState(() {
          _tasks = taskController.tasks;
        });

        filterTasks();
      });
    } else {
      await taskController.reload();
    }

    await taskController.future;

    final elder = (await supabase.getCurrentUser()).elder;

    setState(() {
      _tasks = taskController.tasks;
      _filteredTasks = _tasks;
      _elder = elder;
    });
  }

  addTask(Task task) {
    setState(() {
      _tasks.add(task);
    });

    filterTasks();
  }

  filterTasks() {
    switch (_filter) {
      case Filter.all:
        setState(() {
          _filteredTasks = _tasks;
        });
        break;
      case Filter.completed:
        setState(() {
          _filteredTasks = _tasks.where((task) => task.completed).toList();
        });
        break;
      case Filter.incomplete:
        setState(() {
          _filteredTasks = _tasks.where((task) => !task.completed).toList();
        });
        break;
    }
  }

  @override
  AppBar get loadingAppBar => AppBar(
        title: const Text('Tasks'),
      );

  @override
  get loadedAppBar => AppBar(
        title: Text('Tasks (${_tasks.length})'),
        actions: [
          if (_elder)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                context.pushNamed(NewTaskPage.routeName);
              },
            )
        ],
      );

  @override
  Widget buildLoaded(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
          child: Row(
            children: [
              const Icon(Icons.filter_alt_outlined),
              const SizedBox(width: 8),
              const Text('Filter by'),
              const SizedBox(width: 8),
              DropdownButton<Filter>(
                value: _filter,
                onChanged: (value) {
                  setState(() {
                    _filter = value!;
                  });

                  filterTasks();
                },
                style: subtitleStyle,
                items: const [
                  DropdownMenuItem(
                    value: Filter.all,
                    child: Text('All'),
                  ),
                  DropdownMenuItem(
                    value: Filter.completed,
                    child: Text('Completed'),
                  ),
                  DropdownMenuItem(
                    value: Filter.incomplete,
                    child: Text('Incomplete'),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            itemCount: _filteredTasks.length,
            itemBuilder: (context, index) {
              final task = _filteredTasks[index];
              return TaskView(task: task);
            },
          ),
        ),
      ],
    );
  }
}

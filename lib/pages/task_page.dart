import 'package:age_sync/utils/loading_state.dart';
import 'package:age_sync/utils/task.dart';
import 'package:flutter/material.dart';

import '../utils/constants.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  static const routeName = '/task';

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends LoadingState<TaskPage> {
  late final List<Task> _assignedTasks;
  late final List<Task> _createdTasks;

  @override
  AppBar get loadingAppBar => AppBar(
        title: const Text('Tasks'),
      );

  AppBar get loadedAppBar => AppBar(
        title: const Text('Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.showMenu([]);
            },
          ),
        ],
      );

  @override
  Future<void> onInit() async {
    _assignedTasks = await Task.assignedFromProfileId(supabase.userId);
    _createdTasks = await Task.createdFromProfileId(supabase.userId);
  }

  @override
  Widget buildLoaded(BuildContext context) {
    return Column(
      children: [
        ExpansionTile(
          title: Text('Assigned Tasks (${_assignedTasks.length})'),
          children:
              _assignedTasks.map((task) => TaskEntry(task: task)).toList(),
        ),
        ExpansionTile(
          title: Text('Created Tasks (${_createdTasks.length})'),
          children: _createdTasks.map((task) => TaskEntry(task: task)).toList(),
        ),
      ],
    );
  }
}

class TaskEntry extends StatefulWidget {
  const TaskEntry({super.key, required this.task});

  final Task task;

  @override
  State<TaskEntry> createState() => _TaskEntryState();
}

class _TaskEntryState extends State<TaskEntry> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.task.name),
      subtitle: Text(widget.task.details),
      trailing: widget.task.completed
          ? const Icon(Icons.check)
          : const Icon(Icons.circle_outlined),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(widget.task.name, style: titleStyle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(widget.task.details),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  widget.task.toggleCompleted();
                  setState(() {});
                  context.pop();
                },
                child: Text(widget.task.completed
                    ? 'Mark Uncompleted'
                    : 'Mark Completed'),
              ),
              TextButton(
                onPressed: () {
                  context.pop();
                },
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }
}

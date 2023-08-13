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
  late final List<Task> _tasks;
  late final bool _elder;

  @override
  AppBar get loadingAppBar => AppBar(
        title: const Text('Tasks'),
      );

  @override
  AppBar? get loadedAppBar => AppBar(
        title: Text('Tasks (${_tasks.length})'),
        actions: [
          _elder
              ? IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    context.showMenu([]);
                  },
                )
              : Container()
        ],
      );

  @override
  Future<void> onInit() async {
    _elder = (await supabase.getCurrentUser()).elder;
    _tasks = await Task.getTasks(await supabase.getCurrentUser());
  }

  @override
  Widget buildLoaded(BuildContext context) {
    return Column(
        children: _tasks.map((task) => TaskEntry(task: task)).toList()
          ..sort((a, b) => a.task.completed ? 1 : -1));
  }
}

class TaskEntry extends StatefulWidget {
  const TaskEntry({super.key, required this.task, this.ownerName});

  final Task task;
  final String? ownerName;

  @override
  State<TaskEntry> createState() => _TaskEntryState();
}

class _TaskEntryState extends State<TaskEntry> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.task.name,
          style: subtitleStyle.copyWith(
            decoration:
                widget.task.completed ? TextDecoration.lineThrough : null,
            overflow: TextOverflow.ellipsis,
          )),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'By ${widget.ownerName ?? 'me'}',
            style: metaStyle,
          ),
          Text(widget.task.details,
              style: metaStyle, overflow: TextOverflow.ellipsis),
        ],
      ),
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

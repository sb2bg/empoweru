import 'package:age_sync/utils/loading_state.dart';
import 'package:age_sync/utils/task.dart';
import 'package:age_sync/widgets/task_view.dart';
import 'package:flutter/material.dart';

import '../utils/constants.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  static const routeName = '/task';

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends LoadingState<TaskPage> {
  late List<Task> _tasks;
  late bool _elder;

  @override
  Future<void> onInit() async {
    final elder = (await supabase.getCurrentUser()).elder;
    final tasks = await Task.getTasks(await supabase.getCurrentUser());

    setState(() {
      _tasks = tasks;
      _elder = elder;
    });
  }

  @override
  AppBar get loadingAppBar => AppBar(
        title: const Text('Tasks'),
      );

  @override
  get loadedAppBar => AppBar(
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
  Widget buildLoaded(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemCount: _tasks.length,
      itemBuilder: (context, index) {
        final task = _tasks[index];
        return TaskView(task: task);
      },
    );
  }
}

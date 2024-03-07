import 'package:age_sync/utils/task.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../utils/constants.dart';
import '../utils/profile.dart';

class TaskView extends StatefulWidget {
  const TaskView({super.key, required this.task});

  final Task task;

  @override
  State<TaskView> createState() => _TaskViewState();
}

class _TaskViewState extends State<TaskView> {
  String? _name;
  late final bool _owner;

  @override
  void initState() {
    super.initState();

    // TODO: cache names
    Profile.fromId(widget.task.ownerId).then((profile) {
      setState(() {
        _name = profile.name;
        _owner = widget.task.ownerId == supabase.userId;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.task.name,
                  style: titleStyle,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'By ${_name ?? 'Unknown'} ${DateFormat.yMMMMd().format(widget.task.createdAt)}',
                  style: whiteMetaStyle,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Due ${DateFormat.yMMMMd().format(widget.task.deadline)}',
                  style: whiteMetaStyle,
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.task.details, style: subtitleStyle),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  taskController.toggleTask(widget.task);
                  setState(() {});
                  context.pop();
                },
                child: Text(
                  widget.task.completed ? 'Mark Incomplete' : 'Mark Complete',
                  style: TextStyle(
                    color: widget.task.completed
                        ? Colors.redAccent
                        : Colors.lightGreen,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  context.pop();
                  context.pushNamed(
                    '/task/${widget.task.id}',
                    arguments: widget.task,
                  );
                },
                child: const Text('Edit'),
              ),
              if (_owner)
                TextButton(
                  onPressed: () {
                    // taskController.deleteTask(widget.task);
                    // setState(() {});
                    context.pop();
                  },
                  child: const Text('Delete'),
                ),
            ],
          ),
        );
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: AnimatedCrossFade(
                          duration: const Duration(milliseconds: 250),
                          crossFadeState: widget.task.completed
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          firstChild: Text(
                            widget.task.name,
                            style: subtitleStyle,
                            overflow: TextOverflow.ellipsis,
                          ),
                          secondChild: Text(
                            widget.task.name,
                            style: subtitleStyle.copyWith(
                                decoration: TextDecoration.lineThrough),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'by ${_name ?? 'Unknown'} on ${DateFormat.yMMMMd().format(widget.task.createdAt)}',
                    style: metaStyle.copyWith(
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                      widget.task.completed
                          ? 'Completed'
                          : 'due ${DateFormat.yMMMMd().format(widget.task.deadline)} • repeats ${widget.task.repeat.name}',
                      style: metaStyle,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(
                    widget.task.details,
                    style: metaStyle.copyWith(color: Colors.white),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  taskController.toggleTask(widget.task);
                  setState(() {});
                },
                icon: Icon(
                  widget.task.completed
                      ? Icons.check_box
                      : Icons.check_box_outline_blank,
                  color: widget.task.completed ? Colors.green : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

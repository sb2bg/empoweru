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

  @override
  void initState() {
    super.initState();

    Profile.fromId(widget.task.ownerId).then((profile) {
      setState(() {
        _name = profile.name;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.task.name,
                        style: titleStyle, overflow: TextOverflow.ellipsis),
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
        child: ListTile(
          title: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 250),
                crossFadeState: widget.task.completed
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: Expanded(
                  child: Text(
                    widget.task.name,
                    style: subtitleStyle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                secondChild: Expanded(
                  child: Text(
                    widget.task.name,
                    style: subtitleStyle.copyWith(
                        decoration: TextDecoration.lineThrough),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
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
            ],
          ),
          subtitle: Text(widget.task.details,
              style: metaStyle.copyWith(color: Colors.white, fontSize: 14)),
          trailing: Checkbox(
            value: widget.task.completed,
            onChanged: (value) {
              taskController.toggleTask(widget.task);
              setState(() {});
            },
          ),
        ),
      ),
    );
  }
}

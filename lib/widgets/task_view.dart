import 'package:age_sync/utils/task.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart';

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
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.task.name, style: titleStyle),
                Text(
                  'By ${_name ?? 'Unknown'} ${DateFormat.yMMMMd().format(widget.task.createdAt)}',
                  style: whiteMetaStyle,
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
      child: ListTile(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AnimatedCrossFade(
                    duration: const Duration(milliseconds: 250),
                    crossFadeState: widget.task.completed
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    firstChild: Text(widget.task.name, style: subtitleStyle),
                    secondChild: Text(widget.task.name,
                        style: subtitleStyle.copyWith(
                            decoration: TextDecoration.lineThrough))),
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
                    : 'due ${DateFormat.yMMMMd().format(widget.task.deadline)}',
                style: metaStyle),
            const SizedBox(height: 4),
          ],
        ),
        subtitle: Text(widget.task.details, style: metaStyle),
        trailing: Checkbox(
          value: widget.task.completed,
          onChanged: (value) async {
            widget.task.toggleCompleted();
            setState(() {});
          },
        ),
      ),
    );
  }
}

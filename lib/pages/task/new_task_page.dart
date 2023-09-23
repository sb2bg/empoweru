import 'package:age_sync/utils/task_repeat.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../utils/constants.dart';
import '../../utils/task.dart';

class NewTaskPage extends StatefulWidget {
  static const String routeName = '/new-task';

  const NewTaskPage({super.key, this.start});

  final DateTime? start;

  @override
  State<NewTaskPage> createState() => _NewTaskPageState();
}

class _NewTaskPageState extends State<NewTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final _taskNameController = TextEditingController();
  final _taskDescriptionController = TextEditingController();
  late DateTime _taskDate;
  TaskRepeat _repeat = TaskRepeat.never;
  late Offset _offset;

  @override
  void initState() {
    super.initState();

    _taskDate = widget.start ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Task'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _taskNameController,
              decoration: const InputDecoration(
                hintText: 'Task Name',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a task name';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _taskDescriptionController,
              decoration: const InputDecoration(
                hintText: 'Task Description',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a task description';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(
                      onPressed: () async {
                        final time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now()) ??
                            TimeOfDay.now();

                        final date = DateTime(_taskDate.year, _taskDate.month,
                            _taskDate.day, time.hour, time.minute);

                        if (date != _taskDate) {
                          setState(() {
                            _taskDate = date;
                          });
                        }
                      },
                      icon: const Icon(Icons.access_time),
                      label: Text(DateFormat.jm().format(_taskDate)),
                    ),
                    Listener(
                      onPointerDown: (event) {
                        _offset = event.position;
                      },
                      child: TextButton.icon(
                          onPressed: () {
                            showMenu(
                              context: context,
                              position: RelativeRect.fromLTRB(
                                _offset.dx,
                                _offset.dy,
                                MediaQuery.of(context).size.width - _offset.dx,
                                MediaQuery.of(context).size.height - _offset.dy,
                              ),
                              items: [
                                for (final repeat in TaskRepeat.values)
                                  PopupMenuItem(
                                    value: repeat,
                                    child: Text(repeat.name),
                                  )
                              ],
                            ).then((value) {
                              if (value != null) {
                                setState(() {
                                  _repeat = value;
                                });
                              }
                            });
                          },
                          icon: const Icon(Icons.repeat),
                          label: Text('Repeat ${_repeat.name}')),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(
                        onPressed: () async {
                          final date = await showDatePicker(
                                  context: context,
                                  initialDate: _taskDate,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2101)) ??
                              _taskDate;

                          if (date != _taskDate) {
                            setState(() {
                              _taskDate = date;
                            });
                          }
                        },
                        icon: const Icon(Icons.calendar_today),
                        label: Text(DateFormat.yMMMMd().format(_taskDate))),
                    TextButton.icon(
                      icon: const Icon(Icons.person),
                      onPressed: () async {
                        // final profile = await context.pushNamed('/select-profile');

                        // if (profile != null) {
                        //   setState(() {
                        //     _taskNameController.text = profile.name;
                        //   });
                        // }
                      },
                      label: const Text('Assign to'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  Task.createTask(
                    name: _taskNameController.text,
                    details: _taskDescriptionController.text,
                    deadline: _taskDate,
                    repeat: _repeat,
                  ).then((task) {
                    taskController.addTask(task);
                    context.pop();
                  });
                }
              },
              child: const Text('Create Task'),
            ),
          ],
        ),
      ),
    );
  }
}

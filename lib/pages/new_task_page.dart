import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../utils/constants.dart';
import '../utils/task.dart';

class NewTaskPage extends StatefulWidget {
  static const String routeName = '/new-task';

  const NewTaskPage({super.key, required this.tasks});

  final List<Task> tasks;

  @override
  State<NewTaskPage> createState() => _NewTaskPageState();
}

class _NewTaskPageState extends State<NewTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final _taskNameController = TextEditingController();
  final _taskDescriptionController = TextEditingController();
  DateTime _taskDate = DateTime.now();

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
                    TextButton.icon(
                        onPressed: () {
                          print('Open repeat dialog which, when opened, will '
                              'show a list of options for repeating the task such as daily, weekly, monthly, etc.');
                        },
                        icon: const Icon(Icons.repeat),
                        label: const Text('Repeat')),
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
                  ).then((task) {
                    widget.tasks.add(task);
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

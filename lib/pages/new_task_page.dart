import 'package:flutter/material.dart';

import '../../utils/constants.dart';
import '../utils/task.dart';

class NewTaskPage extends StatefulWidget {
  const NewTaskPage({super.key});

  static const String routeName = '/new-task';

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
                labelText: 'Task Name',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a task name';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _taskDescriptionController,
              decoration: const InputDecoration(
                labelText: 'Task Description',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a task description';
                }
                return null;
              },
            ),
            TextButton.icon(
                onPressed: () async {
                  final date = await showDatePicker(
                          context: context,
                          initialDate: _taskDate,
                          firstDate: DateTime(2015, 8),
                          lastDate: DateTime(2101)) ??
                      _taskDate;

                  if (date != _taskDate) {
                    setState(() {
                      _taskDate = date;
                    });
                  }
                },
                icon: const Icon(Icons.calendar_today),
                label: const Text("Pick a date")),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  Task.createTask(
                    name: _taskNameController.text,
                    details: _taskDescriptionController.text,
                    deadline: DateTime.now().add(const Duration(days: 7)),
                  ).then((task) {
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

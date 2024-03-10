import 'dart:collection';

import 'package:age_sync/pages/task/new_task_page.dart';
import 'package:age_sync/utils/profile.dart';
import 'package:age_sync/utils/task_repeat.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../utils/constants.dart';
import '../../utils/loading_state.dart';
import '../../utils/task.dart';
import '../../widgets/task_view.dart';

class CalendarPage extends StatefulWidget {
  static const routeName = '/calendar';

  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends LoadingState<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  late List<Task> _selectedTasks;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  late LinkedHashMap<DateTime, List<Task>> _events;
  late Profile _profile;

  @override
  AppBar get constAppBar => AppBar(
        title: const Text('Events'),
      );

  List<Task> _getEvents(List<Task> tasks) {
    _events = LinkedHashMap(
      equals: isSameDay,
      hashCode: (date) => date.day ^ date.month ^ date.year,
    );

    _events.addAll(
      tasks.fold(
        <DateTime, List<Task>>{},
        (map, task) {
          final date = task.deadline;
          map[date] = [...(map[date] ?? []), task];
          return map;
        },
      ),
    );

    return _events[_focusedDay] ?? [];
  }

  @override
  firstLoad() async {
    await taskController.ready;

    taskController.addListener(() {
      final tasks = taskController.tasks;

      setState(() {
        _getEvents(tasks);
        _selectedTasks = getTasksForDay(_focusedDay);
      });
    });
  }

  @override
  Future<void> onInit() async {
    _profile = await supabase.getCurrentUser();

    setState(() {
      _focusedDay = DateTime.now();
      _selectedTasks = _getEvents(taskController.tasks);
    });
  }

  List<Task> getTasksForDay(DateTime day) {
    List<Task> tasks = [];

    List<Task> allEvents = _events.values
        .expand((element) => element)
        .where((element) =>
            day.isAfter(element.deadline) || isSameDay(day, element.deadline))
        .toList();

    tasks.addAll(allEvents
        .where((event) =>
            event.repeat == TaskRepeat.daily ||
            (event.deadline.weekday == day.weekday &&
                event.repeat == TaskRepeat.weekly) ||
            (event.deadline.day == day.day &&
                event.repeat == TaskRepeat.monthly) ||
            (event.deadline.day == day.day &&
                event.deadline.month == day.month &&
                event.repeat == TaskRepeat.yearly) ||
            (event.repeat == TaskRepeat.never &&
                isSameDay(event.deadline, day)))
        .toList());

    return tasks;
  }

  @override
  Widget buildLoaded(BuildContext context) {
    return Column(
      children: [
        TableCalendar(
          focusedDay: _focusedDay,
          firstDay: DateTime.utc(2023, 8, 0),
          lastDay: DateTime.utc(2030, 3, 14),
          selectedDayPredicate: (day) {
            return isSameDay(_focusedDay, day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _focusedDay = focusedDay;
              _selectedTasks = getTasksForDay(selectedDay);
            });
          },
          eventLoader: getTasksForDay,
          availableCalendarFormats: const {
            CalendarFormat.month: 'Month',
            CalendarFormat.week: 'Week',
          },
          calendarFormat: _calendarFormat,
          onFormatChanged: (format) {
            setState(() {
              _calendarFormat = format;
            });
          },
          calendarStyle: CalendarStyle(
            outsideDaysVisible: false,
            markerDecoration: BoxDecoration(
              color: themeData.colorScheme.primary,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: themeData.colorScheme.primary.withOpacity(0.25),
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: themeData.colorScheme.primary.withOpacity(0.6),
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Divider(),
        if (_profile.organization)
          Column(
            children: [
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('Add Task'),
                onTap: () => context.pushNamed(NewTaskPage.routeName,
                    arguments: _focusedDay),
              ),
              const Divider(),
            ],
          ),
        EventView(tasks: _selectedTasks)
      ],
    );
  }
}

class EventView extends StatefulWidget {
  const EventView({super.key, required this.tasks});

  final List<Task> tasks;

  @override
  State<EventView> createState() => _EventViewState();
}

class _EventViewState extends State<EventView> {
  @override
  Widget build(BuildContext context) {
    final children = widget.tasks.isEmpty
        ? [
            const ListTile(
              title: Text('No tasks due this day', style: subtitleStyle),
            )
          ]
        : widget.tasks.map((task) => TaskView(task: task)).toList();

    return Expanded(
      child: ListView(
        shrinkWrap: true,
        children: children,
      ),
    );
  }
}

import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../utils/constants.dart';
import '../utils/loading_state.dart';
import '../utils/task.dart';
import '../widgets/task_view.dart';

class CalendarPage extends StatefulWidget {
  static const routeName = '/calendar';

  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends LoadingState<CalendarPage> {
  late DateTime _focusedDay;
  late List<Task> _selectedTasks;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  late LinkedHashMap<DateTime, List<Task>> _events;

  @override
  AppBar get constAppBar => AppBar(
        title: const Text('Events'),
      );

  @override
  Future<void> onInit() async {
    final List<Task> tasks =
        await Task.getTasks(await supabase.getCurrentUser());

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

    setState(() {
      _focusedDay = DateTime.now();
      _selectedTasks = _events[_focusedDay] ?? [];
    });
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
              _selectedTasks = _events[selectedDay] ?? [];
            });
          },
          eventLoader: (day) {
            return _events[day] ?? [];
          },
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

    return ListView(
      shrinkWrap: true,
      children: children,
    );
  }
}

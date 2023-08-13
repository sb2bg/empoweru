import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../utils/constants.dart';
import '../utils/loading_state.dart';
import '../utils/task.dart';

class CalendarPage extends StatefulWidget {
  static const routeName = '/calendar';

  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends LoadingState<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  final LinkedHashMap<DateTime, List<Task>> _events = LinkedHashMap(
    equals: isSameDay,
    hashCode: (date) => date.day ^ date.month ^ date.year,
  );

  @override
  AppBar get constAppBar => AppBar(
        title: const Text('Events'),
      );

  @override
  Future<void> onInit() async {
    final List<Task> tasks =
        await Task.getTasks(await supabase.getCurrentUser());

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

    print(_events);
  }

  @override
  Widget buildLoaded(BuildContext context) {
    return TableCalendar(
      focusedDay: _focusedDay,
      firstDay: DateTime.utc(2023, 8, 0),
      lastDay: DateTime.utc(2030, 3, 14),
      onFormatChanged: (format) {},
      selectedDayPredicate: (day) {
        return isSameDay(_focusedDay, day);
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _focusedDay = focusedDay;
        });
      },
      eventLoader: (day) {
        return _events[day] ?? [];
      },
      calendarStyle: CalendarStyle(
        markerDecoration: BoxDecoration(
          color: themeData.colorScheme.primary,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:get/get.dart';
import '../controllers/task_controller.dart';
import '../models/task.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  final TaskController taskController = Get.find<TaskController>();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  Map<DateTime, List<Task>> _events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadEvents();
  }

  void _loadEvents() {
    _events = {};
    for (var task in taskController.tasks) {
      if (task.dueDate != null) {
        final date = DateTime(
          task.dueDate!.year,
          task.dueDate!.month,
          task.dueDate!.day,
        );
        if (_events[date] == null) _events[date] = [];
        _events[date]!.add(task);
      }
      final deadlineDate = DateTime(
        task.deadline.year,
        task.deadline.month,
        task.deadline.day,
      );
      if (_events[deadlineDate] == null) _events[deadlineDate] = [];
      if (!_events[deadlineDate]!.contains(task)) {
        _events[deadlineDate]!.add(task);
      }
    }
  }

  List<Task> _getEventsForDay(DateTime day) {
    final date = DateTime(day.year, day.month, day.day);
    return _events[date] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar<Task>(
          firstDay: DateTime.now().subtract(const Duration(days: 365)),
          lastDay: DateTime.now().add(const Duration(days: 365)),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          eventLoader: _getEventsForDay,
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          onFormatChanged: (format) {
            setState(() {
              _calendarFormat = format;
            });
          },
          calendarStyle: const CalendarStyle(
            markersMaxCount: 3,
            markerSize: 8,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Obx(() {
            _loadEvents();
            final selectedDayEvents = _getEventsForDay(_selectedDay!);
            return ListView.builder(
              itemCount: selectedDayEvents.length,
              itemBuilder: (context, index) {
                final task = selectedDayEvents[index];
                return ListTile(
                  title: Text(task.title),
                  subtitle: Text(task.description ?? ''),
                  leading: Icon(
                    task.isCompleted
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                  ),
                  onTap: () => taskController.toggleTaskStatus(task),
                );
              },
            );
          }),
        ),
      ],
    );
  }
}

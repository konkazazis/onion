import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class CalendarWidget extends StatelessWidget {
  final CalendarFormat calendarFormat;
  final DateTime selectedDay;
  final DateTime focusedDay;
  final Function(DateTime, DateTime) onDaySelected;
  final Function(DateTime) onPageChanged;
  final Function(CalendarFormat) onFormatChanged;
  final List<Map<String, dynamic>> Function(DateTime) eventLoader;
  final Map<String, Color> shiftColors;

  const CalendarWidget({
    super.key,
    required this.calendarFormat,
    required this.selectedDay,
    required this.focusedDay,
    required this.onDaySelected,
    required this.onPageChanged,
    required this.onFormatChanged,
    required this.eventLoader,
    required this.shiftColors,
  });

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      weekNumbersVisible: true,
      firstDay: DateTime.utc(2000, 1, 1),
      lastDay: DateTime.utc(2100, 12, 31),
      focusedDay: focusedDay,
      calendarFormat: calendarFormat,
      onFormatChanged: onFormatChanged,
      selectedDayPredicate: (day) => isSameDay(selectedDay, day),
      onDaySelected: onDaySelected,
      onPageChanged: onPageChanged,
      eventLoader: eventLoader,
      calendarStyle: const CalendarStyle(
        todayDecoration: BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle),
        selectedDecoration: BoxDecoration(color: Colors.deepOrange, shape: BoxShape.circle),
      ),
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, date, events) {
          if (events.isEmpty) return const SizedBox.shrink();
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: events.take(3).map((event) {
              final shift = event as Map<String, dynamic>;
              final shiftType = shift['workType']?.toLowerCase() ?? '';
              final color = shiftColors[shiftType] ?? Colors.grey;

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 1.0),
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              );
            }).toList(),
          );
        },
      ),
      headerStyle: const HeaderStyle(
        formatButtonVisible: true,
        titleCentered: true,
      ),
    );
  }
}

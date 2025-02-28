import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:picnic_search/shift_scheduler.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Import intl package
import 'events.dart';
import 'widgets/dropdown.dart';
import 'shift_scheduler.dart';

class CalendarWidget extends StatefulWidget {
  @override
  _CalendarWidgetState createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  List<Map<String, dynamic>> _events = [];
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  final EventService _eventService = EventService();
  bool _isLoading = true; // Loading state

  @override
  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now(); // Ensure selected day is today
    _focusedDay = DateTime.now();
    _fetchEventsForSelectedDay(); // Fetch today's events immediately
  }

  void _fetchEventsForSelectedDay() async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });

    String formattedDate = DateFormat('dd-MM-yyyy').format(_selectedDay);
    List<Map<String, dynamic>> events =
        await _eventService.fetchEvents(formattedDate);

    setState(() {
      _events = events;
      _isLoading = false; // Hide loading indicator
    });
  }

  Future<void> loadEvents(String date) async {
    setState(() {
      _isLoading = true;
    });

    List<Map<String, dynamic>> fetchedEvents =
        await _eventService.fetchEvents(date);

    setState(() {
      _events = fetchedEvents;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2000, 1, 1),
              lastDay: DateTime.utc(2100, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });

                String formattedDate =
                    DateFormat('dd-MM-yyyy').format(selectedDay);
                loadEvents(formattedDate);
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.blueAccent,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.deepOrange,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _events.isEmpty
                      ? Center(child: Text("No events found for this day"))
                      : ListView.builder(
                          itemCount: _events.length,
                          itemBuilder: (context, index) {
                            var event = _events[index];
                            return ListTile(
                              title: Text(event['event']),
                              subtitle: Text('Date: ${event['date']}'),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ShiftScheduler()),
          );
        },
        child: Icon(Icons.add),
        tooltip: 'Add Event',
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
    );
  }
}

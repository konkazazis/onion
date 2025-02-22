import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Import intl package
import 'events.dart';

class CalendarWidget extends StatefulWidget {
  @override
  _CalendarWidgetState createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  final EventService _eventService = EventService();
  List<Map<String, dynamic>> _events = [];

  @override
  void initState() {
    super.initState();
    _fetchEventsForSelectedDay();
  }

  void _fetchEventsForSelectedDay() async {
    String dateString =
        _selectedDay.toIso8601String().split('T')[0]; // e.g., "2025-02-17"
    List<Map<String, dynamic>> events =
        await _eventService.fetchEvents(dateString);
    setState(() {
      _events = events;
    });
  }

  void _addEvent(String eventTitle, String eventDate) {
    if (eventTitle.isNotEmpty) {
      _eventService.addEvent(eventTitle, eventDate);
      setState(() {
        _fetchEventsForSelectedDay(); // Refresh events after adding
      });
    }
  }

  void _showAddEventDialog() {
    TextEditingController _eventController = TextEditingController();
    TextEditingController _dateController = TextEditingController();
    DateTime? _selectedDate;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add Event"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Event Title input
              TextField(
                controller: _eventController,
                decoration: InputDecoration(
                  labelText: 'Event Title',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              // Date field that triggers the date picker
              GestureDetector(
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                    builder: (BuildContext context, Widget? child) {
                      return Theme(
                        data: ThemeData.light().copyWith(
                          primaryColor: Colors.blueAccent,
                          //accentColor: Colors.blueAccent,
                          buttonTheme: ButtonThemeData(
                            textTheme: ButtonTextTheme.primary,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );

                  if (pickedDate != null) {
                    setState(() {
                      _selectedDate = pickedDate;
                      _dateController.text = DateFormat('dd-MM-yyyy')
                          .format(pickedDate); // Set date in text field
                    });
                  }
                },
                child: AbsorbPointer(
                  // Prevent typing and ensure only the date picker triggers
                  child: TextField(
                    controller: _dateController,
                    decoration: InputDecoration(
                      labelText: 'Event Date',
                      border: OutlineInputBorder(),
                      hintText: _selectedDate != null
                          ? DateFormat('dd-MM-yyyy').format(_selectedDate!)
                          : 'Select a date',
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            // Cancel button
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            // Add event button
            ElevatedButton(
              onPressed: () {
                String eventTitle = _eventController.text;

                // Ensure the title is not empty and a date is selected
                if (eventTitle.isNotEmpty && _selectedDate != null) {
                  String formattedDate =
                      DateFormat('dd-MM-yyyy').format(_selectedDate!);
                  _addEvent(eventTitle, formattedDate);
                  Navigator.of(context).pop(); // Close the dialog
                } else {
                  // Show a message if the title or date is not selected
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Please enter a title and select a date."),
                    ),
                  );
                }
              },
              child: Text('Add Event'),
              style: ElevatedButton.styleFrom(
                //primary: Colors.deepOrange, // Action button color
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar with Events'),
      ),
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
                _fetchEventsForSelectedDay(); // Fetch events for new selected day
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
            // Display events for the selected day
            Expanded(
              child: ListView.builder(
                itemCount: _events.length,
                itemBuilder: (context, index) {
                  var event = _events[index];
                  return ListTile(
                    title: Text(event['event']),
                    subtitle: Text('User ID: ${event['userid']}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEventDialog,
        child: Icon(Icons.add),
        tooltip: 'Add Event',
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}

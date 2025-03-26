import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:picnic_search/profile.dart';
import 'package:table_calendar/table_calendar.dart';
import 'events.dart';
import 'package:intl/intl.dart';
import 'widgets/bottom_nav_bar.dart';
import 'widgets/shift_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final EventService _eventService = EventService();
  List<Map<String, dynamic>> events = [];
  List<Map<String, dynamic>> filteredEvents = [];

  DateTime _selectedDay = DateTime.now(); // The currently selected day
  DateTime _focusedDay = DateTime.now(); // The currently focused day

  bool _isLoading = true;

  // Load events based on the selected day
  Future<void> loadEvents(DateTime selectedDate) async {
    setState(() => _isLoading = true);

    try {
      // Fetch events for the selected date
      final fetchedEvents = await _eventService.fetchEvents(selectedDate);
      setState(() {
        events = fetchedEvents;
        filteredEvents = fetchedEvents;
      });
    } catch (e) {
      log("Error fetching events: $e");
      setState(() {
        filteredEvents = [];
      });
    } finally {
      setState(() => _isLoading = false);
    }

    // Fetch events for a specific month (optional, based on your requirements)
    try {
      var response2 = await _eventService
          .fetchEventsByMonth("03-2025"); // Example month and year
      print(response2);
    } catch (e) {
      log("Error fetching events by month: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now(); // Default to today's date
    _focusedDay =
        _selectedDay; // Set the focused day to the selected day initially
    loadEvents(_selectedDay); // Load events for today's date
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Welcome back, Kostas!',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: kToolbarHeight + 20),
            // Using TableCalendar for better day selection
            TableCalendar(
              firstDay: DateTime.utc(2000, 1, 1),
              lastDay: DateTime.utc(2100, 12, 31),
              focusedDay: _focusedDay, // Focused day
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                // Update selected and focused day when the user selects a day
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });

                // Pass the selected day (DateTime object) to loadEvents
                //loadEvents(selectedDay);
              },
              onFormatChanged: (format) {
                // Handle format change if needed (Month, Week, Day view)
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
            const SizedBox(height: 20),
            const Text(
              "Today's Schedule:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredEvents.isEmpty
                      ? const Center(child: Text("No events found"))
                      : ListView.builder(
                          itemCount: filteredEvents.length,
                          itemBuilder: (context, index) {
                            final event = filteredEvents[index];
                            String eventName = event['event'] ??
                                'No Event'; // Default value if null
                            String eventDate = event['date'] ??
                                'No Date'; // Default value if null
                            return ListTile(
                              leading: const Icon(Icons.event),
                              title: Text(eventName),
                              subtitle: Text("Date: $eventDate"),
                            );
                          },
                        ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Statistics:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ShiftCard(
                  title: "Total hours this month",
                  hours: "8h 30m",
                  earnings: "\$120",
                ),
                ShiftCard(
                  title: "Average Shift",
                  hours: "7h 45m",
                  earnings: "\$110",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: DashboardScreen(),
  ));
}

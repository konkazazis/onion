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

  late DateTime now;
  late String date;

  bool _isLoading = true;

  Future<void> loadEvents(String date) async {
    setState(() => _isLoading = true);

    try {
      // Ensure the date passed is valid
      DateTime selectedDate = DateTime.tryParse(date) ??
          DateTime.now(); // Fallback to current date if invalid

      // Fetch events for the specific date
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

    // Fetch events for a specific month (you can pass the month and year in 'MM-yyyy' format)
    try {
      var response2 = await _eventService
          .fetchEventsByMonth("03-2025"); // Month and year in 'MM-yyyy' format
      print(response2);
    } catch (e) {
      log("Error fetching events by month: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    now = DateTime.now();
    date = DateFormat('yyyy-MM-dd').format(now); // Adjusted to 'yyyy-MM-dd'
    loadEvents(date); // Use the formatted date string
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
            // Using TableCalendar instead of WeeklyCalendar
            TableCalendar(
              firstDay: DateTime.utc(2000, 1, 1),
              lastDay: DateTime.utc(2100, 12, 31),
              focusedDay: now, // Focus on the current day
              selectedDayPredicate: (day) {
                return isSameDay(now, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                // Handle null selectedDay
                if (selectedDay != null) {
                  String formattedDate =
                      DateFormat('yyyy-MM-dd').format(selectedDay);
                  loadEvents(formattedDate); // Pass the formatted date
                } else {
                  log("Selected date is null.");
                }
              },
              onFormatChanged: (format) {
                // Handle format change (Month, Week, Day view)
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
                                'No Event'; // Provide default value if null
                            String eventDate = event['date'] ??
                                'No Date'; // Provide default value if null
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

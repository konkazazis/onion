import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:picnic_search/profile.dart';
import 'package:table_calendar/table_calendar.dart';
import 'services/shifts_service.dart';
import 'package:intl/intl.dart';
import 'widgets/bottom_nav_bar.dart';
import 'widgets/shift_card.dart';
import 'shift_scheduler.dart';

class DashboardScreen extends StatefulWidget {
  final String username;
  final String userID;

  const DashboardScreen(
      {super.key, required this.username, required this.userID});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final shiftsService _shiftsService = shiftsService();
  List<Map<String, dynamic>> events = [];
  List<Map<String, dynamic>> filteredEvents = [];

  DateTime _selectedDay = DateTime.now(); // The currently selected day
  DateTime _focusedDay = DateTime.now(); // The currently focused day

  bool _isLoading = true;

  // Load events based on the selected day
  Future<void> loadShifts(DateTime selectedDate) async {
    setState(() => _isLoading = true);

    try {
      // Fetch events for the selected date
      final fetchedEvents = await _shiftsService.fetchShifts(selectedDate);
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
    // try {
    //   var response2 = await _shiftsService
    //       .fetchShiftsByMonth("03-2025"); // Example month and year
    // } catch (e) {
    //   log("Error fetching events by month: $e");
    // }
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now(); // Default to today's date
    _focusedDay =
        _selectedDay; // Set the focused day to the selected day initially
    loadShifts(_selectedDay); // Load events for today's date
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text.rich(
          TextSpan(
            text: 'Welcome back, ',
            style: TextStyle(color: Colors.black),
            children: [
              TextSpan(
                text: widget.username, // Bold username
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: '!'), // Exclamation mark
            ],
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        // Wrap the body content in a scroll view
        child: Padding(
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
                calendarFormat: CalendarFormat.week,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  loadShifts(selectedDay);
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
              // This part is the key fix, wrapped in a scrollable list
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredEvents.isEmpty
                      ? const Center(child: Text("No events found"))
                      : ListView.builder(
                          shrinkWrap:
                              true, // This will allow the list to be scrollable without needing Expanded
                          physics:
                              NeverScrollableScrollPhysics(), // Disable scroll of ListView as it's inside a scrollable parent
                          itemCount: filteredEvents.length,
                          itemBuilder: (context, index) {
                            final event = filteredEvents[index];
                            String eventName = event['workType'] ?? 'No Event';
                            String eventDate = event['date'] ?? 'No Date';
                            String shiftStart = event['startTime'] ?? '';
                            String shiftEnd = event['endTime'] ?? '';
                            return ListTile(
                                leading: const Icon(Icons.event),
                                title: Text(eventName),
                                subtitle: Text("Date: $eventDate\n" +
                                    "Shift Start: $shiftStart\n" +
                                    "Shift End: $shiftEnd"));
                          },
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ShiftScheduler(userID: widget.userID)),
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

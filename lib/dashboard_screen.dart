import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:picnic_search/profile.dart';
import 'package:table_calendar/table_calendar.dart';
import 'services/shifts_service.dart';
import 'package:intl/intl.dart';
import 'widgets/bottom_nav_bar.dart';
import 'widgets/shift_card.dart';
import 'shift_scheduler.dart';
import 'package:intl/intl.dart';

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

  Duration totalMonthlyDuration = Duration();

  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  bool _isLoading = true;

  // Load events based on the selected day
  Future<void> loadShifts(DateTime selectedDate) async {
    setState(() => _isLoading = true);

    print("Selected month: ${_selectedDay.month}-${_selectedDay.year}");

    try {
      // Fetch events for the selected date
      final fetchedEvents = await _shiftsService.fetchShifts(selectedDate);
      setState(() {
        events = fetchedEvents;
        filteredEvents = fetchedEvents;
        print(filteredEvents);
      });
    } catch (e) {
      log("Error fetching events: $e");
      setState(() {
        filteredEvents = [];
      });
    } finally {
      setState(() => _isLoading = false);
    }

    try {
      var responseMonth = await _shiftsService
          .fetchShiftsByMonth("${_selectedDay.month}-${_selectedDay.year}");
      print("ResponseMonth: $responseMonth");

      Duration calculatedDuration = Duration(); // temporary container

      final dateFormat = DateFormat("HH:mm");

      for (var shift in responseMonth) {
        String start = shift['startTime'];
        String end = shift['endTime'];

        DateTime startTime = dateFormat.parse(start);
        DateTime endTime = dateFormat.parse(end);

        Duration duration = endTime.difference(startTime);

        calculatedDuration += duration;
      }

      setState(() {
        totalMonthlyDuration = calculatedDuration;
      });
    } catch (e) {
      log("Error fetching events by month: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = _selectedDay;
    loadShifts(_selectedDay);
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: kToolbarHeight + 20),
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: Colors.grey,
                    width: 1,
                  ),
                ),
                child: TableCalendar(
                  firstDay: DateTime.utc(2000, 1, 1),
                  lastDay: DateTime.utc(2100, 12, 31),
                  focusedDay: _focusedDay,
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
              ),
              const SizedBox(height: 20),
              // Divider(
              //   color: Colors.grey[200],
              //   thickness: 1,
              //   indent: 20,
              //   endIndent: 20,
              // ),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredEvents.isEmpty
                      ? const Center(child: Text("No shifts found"))
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: filteredEvents.length,
                          itemBuilder: (context, index) {
                            final event = filteredEvents[index];
                            String eventName = event['workType'] ?? 'No Event';
                            String eventDate = event['date'] ?? 'No Date';
                            String shiftStart = event['startTime'] ?? '';
                            String shiftEnd = event['endTime'] ?? '';
                            String notes = event['notes'] ?? '';
                            return Card(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color: Colors.grey,
                                  width: 1,
                                ),
                              ),
                              child: ListTile(
                                selected: false,
                                leading: const Icon(Icons.event),
                                title: Text(eventName),
                                subtitle: Text(
                                  "$eventDate\n$shiftStart - $shiftEnd\n$notes",
                                ),
                              ),
                            );
                          },
                        ),
              const SizedBox(height: 20),
              Divider(
                color: Colors.grey[200],
                thickness: 1,
                indent: 20,
                endIndent: 20,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ShiftCard(
                    title: "Total hours this month",
                    hours:
                        "${totalMonthlyDuration.inHours}h ${totalMonthlyDuration.inMinutes.remainder(60)}m",
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

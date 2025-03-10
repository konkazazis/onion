import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:picnic_search/profile.dart';
import 'package:weekly_calendar/weekly_calendar.dart';
import 'events.dart';
import 'package:intl/intl.dart';
import 'widgets/bottom_nav_bar.dart';
import 'widgets/shift_card.dart';
import 'dart:developer';

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
      // Parse the string `date` into a DateTime object (assuming it's in the format 'yyyy-MM-dd')
      DateTime selectedDate = DateTime.parse(date);

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
    date = DateFormat('dd-MM-yyyy').format(now);
    loadEvents(date);
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
            Center(
              child: WeeklyCalendar(
                calendarStyle: const CalendarStyle(
                  locale: "en",
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(14)),
                  ),
                  headerDateTextAlign: Alignment.centerLeft,
                  headerDateTextColor: Colors.black,
                  footerDateTextColor: Colors.grey,
                  isShowFooterDateText: true,
                ),
                onChangedSelectedDate: (selectedDate) {
                  String formattedDate =
                      DateFormat('dd-MM-yyyy').format(selectedDate);
                  loadEvents(formattedDate);
                },
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
                            return ListTile(
                              leading: const Icon(Icons.event),
                              title: Text(event['event']),
                              subtitle: Text("Date: ${event['date']}"),
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

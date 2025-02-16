import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:weekly_calendar/weekly_calendar.dart';
import 'events.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final EventService _eventService = EventService();
  List<Map<String, dynamic>> events = [];
  List<Map<String, dynamic>> filteredEvents = [];

  late DateTime now;
  late String date;

  bool _isLoading = true; // Loading state

  Future<void> loadEvents(String date) async {
    setState(() {
      _isLoading = true;
    });

    events = await _eventService.fetchEvents(date);

    setState(() {
      filteredEvents = events;
      _isLoading = false;
    });
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
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundImage: NetworkImage(
              'https://via.placeholder.com/150', // Replace with actual image URL
            ),
          ),
        ),
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
                  loadEvents(formattedDate); // Fetch events for the new date
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
                  ? const Center(
                      child: CircularProgressIndicator()) // Show loading
                  : filteredEvents.isEmpty
                      ? const Center(
                          child: Text("No events found")) // No events message
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
          ],
        ),
      ),
      backgroundColor: const Color(0xFFEDE8D0),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: DashboardScreen(),
  ));
}

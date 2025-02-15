import 'package:flutter/material.dart';
import 'package:weekly_calendar/weekly_calendar.dart';
import 'events.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final EventService _eventService = EventService();
  List<Map<String, dynamic>> events = [];
  List<Map<String, dynamic>> filteredEvents = [];
  bool _isLoading = true; // Loading state

  Future<void> loadEvents() async {
    setState(() {
      _isLoading = true;
    });

    events = await _eventService.fetchEvents();

    setState(() {
      filteredEvents = events;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    loadEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Fully transparent
        elevation: 0, // No shadow
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
          style: TextStyle(color: Colors.black), // Adjust text color
        ),
        centerTitle: true, // Centers the title
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: kToolbarHeight + 20), // Space below AppBar
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
                onChangedSelectedDate: (date) {
                  debugPrint("onChangedSelectedDate: $date");
                  // a function should be called that requests the tasks for
                  // the selected date
                },
              ),
            ),
            const SizedBox(height: 20), // Space before schedule
            const Text(
              "Today's Schedule:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView(
                children: const [
                  // there, the results of the task fetch should be displayed for
                  // each day
                  ListTile(
                    leading: Icon(Icons.event),
                    title: Text("Meeting with Team"),
                    subtitle: Text("10:00 AM - 11:00 AM"),
                  ),
                  ListTile(
                    leading: Icon(Icons.work),
                    title: Text("Project Review"),
                    subtitle: Text("2:00 PM - 3:30 PM"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFEDE8D0), // Set background color
    );
  }
}

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: DashboardScreen(),
  ));
}

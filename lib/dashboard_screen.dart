import 'package:flutter/material.dart';
import 'package:weekly_calendar/weekly_calendar.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

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
              ),
            ),
            const SizedBox(height: 20), // Add spacing
            const Text(
              "Today's Schedule:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // Placeholder for schedule items
            Expanded(
              child: ListView(
                children: const [
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

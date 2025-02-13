import 'package:flutter/material.dart';
import 'package:weekly_calendar/weekly_calendar.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Ensures content is behind the app bar
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Fully transparent
        elevation: 0, // No shadow
        leading: const Padding(
          padding: const EdgeInsets.all(8.0),
          child: const CircleAvatar(
            backgroundImage: NetworkImage(
              'https://via.placeholder.com/150', // Replace with actual image URL
            ),
          ),
        ),
        title: const Text(
          'Welcome!',
          style: TextStyle(color: Colors.black), // Adjust text color
        ),
        centerTitle: true, // Centers the title
      ),
      body: const Center(
        child: WeeklyCalendar(
          calendarStyle: const CalendarStyle(
            locale: "en",
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.all(Radius.circular(14)),
            ),
            headerDateTextAlign: Alignment.centerLeft,
            headerDateTextColor: Colors.white,
            footerDateTextColor: Colors.grey,
            isShowFooterDateText: true,
          ),
        ),
      ),
      backgroundColor:
          Colors.white, // Set background color for better visibility
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: DashboardScreen(),
  ));
}

import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'calendar.dart';
import 'profile.dart';
import 'widgets/bottom_nav_bar.dart';

class MainScreen extends StatefulWidget {
  final String username;
  final String email;
  final String userID;

  MainScreen(
      {required this.username, required this.email, required this.userID});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  late List<Widget> _pages;

  void initState() {
    super.initState();
    _pages = [
      DashboardScreen(username: widget.username),
      CalendarWidget(userID: widget.userID),
      ProfileComponent(
          name: widget.username, email: widget.email, profileImageUrl: 'test'),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // Only one active screen
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

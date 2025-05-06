import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'profile.dart';

class MainScreen extends StatefulWidget {
  final String created;
  final String username;
  final String email;
  final String userid;

  MainScreen(
      {required this.username, required this.email, required this.userid, required this.created});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  late List<Widget> _pages;

  void initState() {
    super.initState();
    _pages = [
      DashboardScreen(username: widget.username, userid: widget.userid, email: widget.email, created: widget.created),
      ProfileComponent(
          name: widget.username,
          email: widget.email,
          profileImageUrl: 'test',
          userid: widget.userid,
          created: widget.created
      ),
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
      body:
      Padding(padding: EdgeInsets.all(10),
        child: _pages[_selectedIndex],
      )
      // bottomNavigationBar: BottomNavBar(
      //   currentIndex: _selectedIndex,
      //   onTap: _onItemTapped,
      // ),
    );
  }
}

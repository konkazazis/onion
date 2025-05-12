import 'package:flutter/material.dart';
import 'package:onion/personal_activities.dart';
import 'package:onion/shift_scheduler.dart';


class NewActivity extends StatelessWidget {
  final String userid;

  NewActivity({required this.userid});



  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> activityTypes = [
      {'label': 'Work', 'icon': Icons.work, 'route': ShiftScheduler(userid: userid)},
      {'label': 'Personal', 'icon': Icons.person, 'route': PersonalActivities(userid: userid,)},
      {'label': 'Physical', 'icon': Icons.directions_bike, 'route': ShiftScheduler(userid: userid)},
      {'label': 'Social', 'icon': Icons.groups, 'route': ShiftScheduler(userid: userid)},
      {'label': 'Household', 'icon': Icons.house, 'route': ShiftScheduler(userid: userid)},
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Choose your activity",
          style: TextStyle(color: Colors.black, fontSize: 22),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: activityTypes.length,
        itemBuilder: (BuildContext context, int index) {
          return SizedBox(
              height: 180,
              child:
              Card(
            color: Colors.white,
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              leading: Icon(activityTypes[index]['icon'], size: 32),
              title: Text(
                activityTypes[index]['label'],
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => activityTypes[index]['route']),
                );
              },
            ),
          ));
        },
      ),
    );
  }
}
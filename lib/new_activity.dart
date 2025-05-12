import 'package:flutter/material.dart';
import 'package:onion/shift_scheduler.dart';


class NewActivity extends StatelessWidget {
  final String userid;

  NewActivity({required this.userid});



  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> activityTypes = [
      {'label': 'Work', 'icon': Icons.work, 'route': ShiftScheduler(userid: userid)},
      {'label': 'Personal', 'icon': Icons.assignment, 'route': ShiftScheduler(userid: userid)},
      {'label': 'Physical', 'icon': Icons.directions_bike, 'route': ShiftScheduler(userid: userid)},
      {'label': 'Social', 'icon': Icons.people, 'route': ShiftScheduler(userid: userid)},
      {'label': 'Household', 'icon': Icons.home, 'route': ShiftScheduler(userid: userid)}
    ];
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          iconTheme: const IconThemeData(color: Colors.black),
          title: Text("Choose your activity",
              style: const TextStyle(
                  color: Colors.black,

                  fontSize: 22)
          ),
        ),
        body: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: activityTypes.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                margin: const EdgeInsets.all(8.0),
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(8.0),  // Set border radius
                ),
                child:
                  ListTile(
                    leading: Icon(activityTypes[index]['icon']),
                    title: Text(activityTypes[index]['label']),
                    trailing: IconButton(
                        icon: Icon(Icons.chevron_right),
                        onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => activityTypes[index]['route'])
                        );})

                  )
              );
            }
        )
    );
  }

}
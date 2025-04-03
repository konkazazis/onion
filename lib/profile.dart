import 'package:flutter/material.dart';
import 'services/auth_service.dart';

class ProfileComponent extends StatelessWidget {
  final String name;
  final String email;
  final String profileImageUrl;

  const ProfileComponent({
    Key? key,
    required this.name,
    required this.email,
    required this.profileImageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 30),
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        name + " | ",
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        email,
                        style: TextStyle(fontSize: 20, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Divider(
                    color: Colors.grey[200], // Color of the line
                    thickness: 1, // Thickness of the line
                    indent: 0, // Left spacing
                    endIndent: 20, // Right spacing
                  ),
                  Text('Personal Information',
                      style: TextStyle(fontSize: 22, color: Colors.grey[600])),
                  SizedBox(height: 10),
                  Text(
                    'Work Details',
                    style: TextStyle(fontSize: 22, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Notification Settings',
                    style: TextStyle(fontSize: 22, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Change Password',
                    style: TextStyle(fontSize: 22, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 400),
                  _signout(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _signout(BuildContext context) {
    return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
          ),
          onPressed: () async {
            await AuthService().signout(context: context);
          },
          child: const Text(
            "Sign out",
            style: TextStyle(
                color: Color(0xffF7F7F9)), // Correct way to set text color
          ),
        ));
  }
}

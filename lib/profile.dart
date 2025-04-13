import 'package:flutter/material.dart';
import 'package:picnic_search/personal_details.dart';
import 'services/auth_service.dart';

class ProfileComponent extends StatelessWidget {
  final String name;
  final String email;
  final String profileImageUrl;
  final String userID;

  const ProfileComponent(
      {Key? key,
      required this.name,
      required this.email,
      required this.profileImageUrl,
      required this.userID})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(profileImageUrl),
            ),
            const SizedBox(height: 12),
            Text(
              name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              email,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            const Divider(),
            Card(
              color: Colors.white,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: Colors.grey, width: 1),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PersonalDetails(userID: userID, email: email)),
                  );
                },
                child: const ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Personal Details'),
                ),
              ),
            ),
            Card(
              color: Colors.white,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: Colors.grey, width: 1),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => PersonalDetails()),
                  // );
                },
                child: const ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Notification Settings'),
                ),
              ),
            ),
            Card(
              color: Colors.white,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: Colors.grey, width: 1),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => PersonalDetails()),
                  // );
                },
                child: const ListTile(
                  leading: Icon(Icons.event),
                  title: Text('Work Details'),
                ),
              ),
            ),
            Card(
              color: Colors.white,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: Colors.grey, width: 1),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => PersonalDetails()),
                  // );
                },
                child: const ListTile(
                  leading: Icon(Icons.event),
                  title: Text('Change Password'),
                ),
              ),
            ),
            Card(
              color: Colors.white,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: Colors.grey, width: 1),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => PersonalDetails()),
                  // );
                },
                child: const ListTile(
                  leading: Icon(Icons.event),
                  title: Text('Shift History'),
                ),
              ),
            ),
            Card(
              color: Colors.white,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: Colors.grey, width: 1),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => PersonalDetails()),
                  // );
                },
                child: const ListTile(
                  leading: Icon(Icons.event),
                  title: Text('Time-off Requests'),
                ),
              ),
            ),
            _signout(context),
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

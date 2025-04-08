import 'package:flutter/material.dart';
import 'package:picnic_search/personal_details.dart';
import 'services/auth_service.dart';

class ProfileComponent extends StatelessWidget {
  final String name;
  final String email;
  final String profileImageUrl;
  static const List<String> profileOptions = [
    'Personal Information',
    'Notification Settings',
    'Work Details',
    'Change Password'
  ];

  const ProfileComponent({
    Key? key,
    required this.name,
    required this.email,
    required this.profileImageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Info
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(profileImageUrl),
            ),
            const SizedBox(height: 12),
            Text(name,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(email,
                style: const TextStyle(fontSize: 16, color: Colors.grey)),

            const SizedBox(height: 24),
            const Divider(),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: profileOptions.length,
              itemBuilder: (context, index) {
                return Card(
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
                            builder: (context) => PersonalDetails()),
                      );
                      print("Tapped on ${profileOptions[index]}");
                    },
                    child: ListTile(
                      leading: const Icon(Icons.event),
                      title: Text(profileOptions[index]),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),
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

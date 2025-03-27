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
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(profileImageUrl),
            ),
            SizedBox(height: 12),
            Text(
              name,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 6),
            Text(
              email,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 20), // Add some spacing
            _signout(context),
          ],
        ),
      ),
    );
  }

  Widget _signout(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xff0D6EFD),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        minimumSize: const Size(80, 60),
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
    );
  }
}

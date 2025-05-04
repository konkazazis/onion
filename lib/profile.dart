import 'package:flutter/material.dart';
import 'package:picnic_search/personal_details.dart';
import 'services/auth_service.dart';
import 'shift_history.dart';

class ProfileComponent extends StatefulWidget {
  final String name;
  final String email;
  final String profileImageUrl;
  final String userid;

  const ProfileComponent({
    Key? key,
    required this.name,
    required this.email,
    required this.profileImageUrl,
    required this.userid,
  }) : super(key: key);

  @override
  State<ProfileComponent> createState() => _ProfileComponentState();
}

class _ProfileComponentState extends State<ProfileComponent> {
  late String _selectedImage;

  final List<String> stockImages = [
    'https://i.pravatar.cc/150?img=13',
    'https://i.pravatar.cc/150?img=2',
    'https://i.pravatar.cc/150?img=3',
    'https://i.pravatar.cc/150?img=4',
    'https://i.pravatar.cc/150?img=5',
    'https://i.pravatar.cc/150?img=6',
  ];

  @override
  void initState() {
    super.initState();
    _selectedImage = widget.profileImageUrl;
  }

  void _showImagePickerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Profile Picture'),
          content: SizedBox(
            width: double.maxFinite,
            child: GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              children: stockImages.map((url) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedImage = url;
                    });
                    Navigator.pop(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(url),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            Navigator.pop(context, 'refresh');
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => _showImagePickerDialog(context),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(_selectedImage),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.email,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            const Divider(),
            _menuCard(
              icon: Icons.person,
              text: 'Personal Details',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PersonalDetails(
                        userid: widget.userid, email: widget.email),
                  ),
                );
              },
            ),
            _menuCard(
              icon: Icons.settings,
              text: 'Notification Settings',
              onTap: () {
                // Add navigation if available
              },
            ),
            _menuCard(
              icon: Icons.password,
              text: 'Change Password',
              onTap: () {
                // Add navigation if available
              },
            ),
            _menuCard(
              icon: Icons.history,
              text: 'Shift History',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ShiftHistory(
                        userid: widget.userid, email: widget.email),
                  ),
                );
              },
            ),
            _menuCard(
              icon: Icons.timer_off,
              text: 'Time-off Requests',
              onTap: () {
                // Add navigation if available
              },
            ),
            _signout(context),
          ],
        ),
      ),
    );
  }

  Widget _menuCard(
      {required IconData icon,
      required String text,
      required VoidCallback onTap}) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Colors.grey, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: ListTile(
          leading: Icon(icon),
          title: Text(text),
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
          style: TextStyle(color: Color(0xffF7F7F9)),
        ),
      ),
    );
  }
}

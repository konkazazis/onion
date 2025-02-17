import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'dashboard_screen.dart';

import 'login.dart';

void main() async {
  //Firebase Initialize
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(Onion());
}

class Onion extends StatelessWidget {
  const Onion({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Onion',
      theme: ThemeData(scaffoldBackgroundColor: Color(0xFFEDE8D0)),
      home: const DashboardScreen(),
    );
  }
}

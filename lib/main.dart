import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Make sure to import this
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientation BEFORE runApp
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const Onion());
}

class Onion extends StatelessWidget {
  const Onion({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Onion',
      theme: ThemeData(scaffoldBackgroundColor: Colors.white),
      home: Login(),
    );
  }
}

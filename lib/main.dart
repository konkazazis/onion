import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'login.dart';

void main() {
  runApp(Onion());
}

class Onion extends StatelessWidget {
  const Onion({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Onion',
      theme: ThemeData(scaffoldBackgroundColor: Color(0xFFEDE8D0)),
      home: const LoginScreen(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class ShiftHistory extends StatefulWidget {
  final String userID;
  const ShiftHistory({super.key, required this.userID});

  @override
  State<ShiftHistory> createState() => _ShiftHistoryState();

}

class _ShiftHistoryState extends State<ShiftHistory> {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
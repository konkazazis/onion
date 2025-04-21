import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class shiftsService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchShiftsByMonth(String month) async {
    try {
      List<String> parts = month.split('-');
      if (parts.length != 2) {
        throw FormatException("Invalid month format. Expected MM-YYYY");
      }

      int monthNum = int.parse(parts[0]); // "03" → 3
      int year = int.parse(parts[1]); // "2025"

      // Ensure we use UTC dates to match Firestore storage
      DateTime startOfMonth = DateTime.utc(year, monthNum, 1, 0, 0, 0);
      DateTime endOfMonth = DateTime.utc(year, monthNum + 1, 0, 23, 59, 59);

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("shifts")
          .where("date",
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .where("date", isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'date': DateFormat('yyyy-MM-dd').format(data['date'].toDate()),
          'workType': data['workType'] ?? '',
          'startTime': DateFormat('HH:mm').format(data['startTime'].toDate()),
          'endTime': DateFormat('HH:mm').format(data['endTime'].toDate())
        };
      }).toList();
    } catch (e) {
      print("Error fetching events: $e");
      return [];
    }
  }

  Future<void> deleteShift(String id) async {
    try {
      await FirebaseFirestore.instance.collection('shifts').doc(id).delete();
    } catch(e) {
      print("Error deleting shift: $e");
    }
  }
}

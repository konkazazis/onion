import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class shiftsService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchShiftsByMonth(String month, String userid) async {
    try {
      List<String> parts = month.split('-');
      if (parts.length != 2) {
        throw FormatException("Invalid month format. Expected MM-YYYY");
      }

      int monthNum = int.parse(parts[0]);
      int year = int.parse(parts[1]);

      DateTime startOfMonth = DateTime.utc(year, monthNum, 1);
      DateTime endOfMonth = (monthNum == 12)
          ? DateTime.utc(year + 1, 1, 1).subtract(Duration(seconds: 1))
          : DateTime.utc(year, monthNum + 1, 1).subtract(Duration(seconds: 1));

      print('Querying from $startOfMonth to $endOfMonth');

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("shifts")
          .where("userid", isEqualTo: userid)
          .where("date", isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .where("date", isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'date': DateFormat('yyyy-MM-dd').format(data['date'].toDate()),
          'workType': data['workType'] ?? '',
          'startTime': DateFormat('HH:mm').format(data['startTime'].toDate()),
          'endTime': DateFormat('HH:mm').format(data['endTime'].toDate()),
          'notes': data['notes'] ?? '',
          'overtime': data['overtime'] ?? ''
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

  Future<void> editShift({
    required String id,
    DateTime? date,
    DateTime? startTime,
    DateTime? endTime,
    String? workType,
    String? overtime,
    String? notes,
  }) async {
    try {
      Map<String, dynamic> updatedData = {};

      if (date != null) {
        updatedData['date'] = Timestamp.fromDate(date);
      }
      if (startTime != null) {
        updatedData['startTime'] = Timestamp.fromDate(startTime);
      }
      if (endTime != null) {
        updatedData['endTime'] = Timestamp.fromDate(endTime);
      }
      if (workType != null) {
        updatedData['workType'] = workType;
      }
      if (notes != null) {
        updatedData['notes'] = notes;
      }
      if (overtime != null) {
        updatedData['overtime'] = overtime;
      }

      if (updatedData.isNotEmpty) {
        await FirebaseFirestore.instance.collection('shifts').doc(id).update(updatedData);
      } else {
        print("No data provided to update.");
      }
    } catch (e) {
      print("Error editing shift: $e");
    }
  }

}

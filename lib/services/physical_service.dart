import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';


class PhysicalService {

  Future<List<Map<String, dynamic>>> fetchPhysicalByMonth(String month, String userid) async{
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

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("physical")
          .where("userid", isEqualTo: userid)
          .where("date", isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .where("date", isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'date': DateFormat('yyyy-MM-dd').format(data['date'].toDate()),
          'notes': data['notes'] ?? '',
        };
      }).toList();
    } catch (e) {
      print("Error fetching events: $e");
      return [];
    }



  }

  Future<void> addPhysical(DateTime date, String userid, String notes) async {
    try {

      await FirebaseFirestore.instance.collection('physical').add({
        'userid': userid,
        'date': Timestamp.fromDate(date),
        'notes': notes.isEmpty ? "" : notes
      });
    } catch (e) {
      print("Error adding shift: $e");
    }
  }


}

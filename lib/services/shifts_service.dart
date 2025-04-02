import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class shiftsService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchShifts(DateTime date) async {
    try {
      // Convert the input DateTime to a start and end range of that day
      DateTime startOfDay = DateTime(date.year, date.month, date.day);
      DateTime endOfDay =
          startOfDay.add(Duration(days: 1)).subtract(Duration(milliseconds: 1));

      // Query the Firestore collection with the range of that day
      QuerySnapshot querySnapshot = await _db
          .collection("shifts")
          .where("date", isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where("date", isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .get();

      // Map the documents into a list of Maps
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'date': data['date'] is Timestamp
              ? DateFormat('yyyy-MM-dd').format(data['date'].toDate())
              : '', // Convert Timestamp to "YYYY-MM-DD"

          'workType': data['workType']?.toString() ??
              '', // Assuming you have a field called 'workType'

          'startTime': data['startTime'] is Timestamp
              ? DateFormat('HH:mm').format(data['startTime'].toDate())
              : '', // Convert Timestamp to "HH:mm"

          'endTime': data['endTime'] is Timestamp
              ? DateFormat('HH:mm').format(data['endTime'].toDate())
              : '', // Convert Timestamp to "HH:mm"
        };
      }).toList();
    } catch (e) {
      print("Error fetching events: $e");
      return [];
    }
  }

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

      print("Querying from: $startOfMonth to $endOfMonth");

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'userid': doc.id,
          'date': (data['date'] as Timestamp)
              .toDate()
              .toUtc()
              .toString(), // Ensure UTC format
          'event': data['shifts']?.toString() ?? '',
        };
      }).toList();
    } catch (e) {
      print("Error fetching events: $e");
      return [];
    }
  }

  // void addEvent(String? type, DateTime eventDate, TimeOfDay startTime,
  //     TimeOfDay endTime) async {
  //   try {
  //     DateTime startDateTime = DateTime(eventDate.year, eventDate.month,
  //         eventDate.day, startTime.hour, startTime.minute);

  //     DateTime endDateTime = DateTime(eventDate.year, eventDate.month,
  //         eventDate.day, endTime.hour, endTime.minute);

  //     await FirebaseFirestore.instance.collection('events').add({
  //       'event': type,
  //       'start': Timestamp.fromDate(startDateTime),
  //       'end': Timestamp.fromDate(endDateTime),
  //       'userid': 'test',
  //       'date': Timestamp.fromDate(eventDate),
  //     });
  //     print("Event added successfully!");
  //   } catch (e) {
  //     print("Error adding event: $e");
  //   }
  // }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class detailsService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future fetchDetails(String userID) async {
    try {
      QuerySnapshot querySnapshot = await _db
          .collection("details")
          .where("userID", isEqualTo: userID)
          .get();

      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print("Error fetching events: $e");
      return [];
    }
  }

  Future<void> submitDetails(String userID, String email, String company, String location, String position, int brakeTime) async {
    try {
      final querySnapshot = await _db
          .collection("details")
          .where("userID", isEqualTo: userID)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final docId = querySnapshot.docs.first.id;
        await _db.collection("details").doc(docId).set({
          "company": company,
          "position": position,
          "brakeTime": brakeTime,
          "email": email,
          "location": location,
          "userID": userID, // might want to keep this consistent
        });}
      // } else {
      //   // If no existing doc, create one
      //   await _db.collection("details").add({
      //     "company": company,
      //     "position": position,
      //     "brakeTime": brakeTime,
      //     "email": email,
      //     "location": location,
      //     "userID": userID,
      //   });
      // }
    } catch (e) {
      print("Error submitting details: $e");
    }
  }

}

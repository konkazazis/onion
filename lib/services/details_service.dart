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
}

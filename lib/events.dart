import 'package:cloud_firestore/cloud_firestore.dart';

class EventService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchEvents() async {
    try {
      QuerySnapshot querySnapshot = await _db.collection("events").get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        print(data);
        return {
          'userid': doc.id,
          'date': data['date']?.toString() ?? '',
          'event': data['event']?.toString() ?? '',
        };
      }).toList();
    } catch (e) {
      print("Error fetching events: $e");
      return [];
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class EventService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchEvents(String date) async {
    try {
      QuerySnapshot querySnapshot = await _db
          .collection("events")
          .where("date", isEqualTo: date) // Filter by date
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
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

  void addEvent(String title, String eventDate) async {
    try {
      await FirebaseFirestore.instance.collection('events').add({
        'event': title,
        'userid': 'test',
        'date': eventDate,
      });
      print("Event added successfully!");
    } catch (e) {
      print("Error adding event: $e");
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/turf.dart';

class TurfController {
  Future<List<Turf>> getTurfList() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('turfs').get();
      return querySnapshot.docs.map((doc) {
        return Turf.fromMap(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      print("Error fetching turfs: $e");
      return [];
    }
  }
}

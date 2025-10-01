import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:waste_classifier_flutter/models/carbon_footprint_entry.dart'; // Adjust import path if necessary

class CarbonFootprintService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'carbonFootprintEntries'; // Firestore collection name

  // Get all carbon footprint entries
  Stream<List<CarbonFootprintEntry>> getCarbonFootprintEntries() {
    return _firestore.collection(_collectionName).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return CarbonFootprintEntry.fromFirestore(doc.data());
      }).toList();
    });
  }

  // Add a new carbon footprint entry
  Future<void> addCarbonFootprintEntry(CarbonFootprintEntry entry) async {
    await _firestore.collection(_collectionName).add(entry.toFirestore());
  }

  // Update an existing carbon footprint entry
  Future<void> updateCarbonFootprintEntry(String entryId, CarbonFootprintEntry updatedEntry) async {
    await _firestore.collection(_collectionName).doc(entryId).update(updatedEntry.toFirestore());
  }

  // Delete a carbon footprint entry
  Future<void> deleteCarbonFootprintEntry(String entryId) async {
    await _firestore.collection(_collectionName).doc(entryId).delete();
  }
}

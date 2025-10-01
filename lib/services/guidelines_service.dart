import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:waste_classifier_flutter/models/guideline.dart'; // Adjust import path if necessary

class GuidelinesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'guidelines'; // Firestore collection name

  // Get all guidelines
  Stream<List<Guideline>> getGuidelines() {
    return _firestore.collection(_collectionName).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Guideline(
          category: doc['category'],
          description: doc['description'],
        );
      }).toList();
    });
  }

  // Add a new guideline
  Future<void> addGuideline(Guideline guideline) async {
    await _firestore.collection(_collectionName).add({
      'category': guideline.category,
      'description': guideline.description,
    });
  }

  // Update an existing guideline
  Future<void> updateGuideline(String guidelineId, Guideline updatedGuideline) async {
    await _firestore.collection(_collectionName).doc(guidelineId).update({
      'category': updatedGuideline.category,
      'description': updatedGuideline.description,
    });
  }

  // Delete a guideline
  Future<void> deleteGuideline(String guidelineId) async {
    await _firestore.collection(_collectionName).doc(guidelineId).delete();
  }
}

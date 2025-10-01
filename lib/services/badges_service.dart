import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:waste_classifier_flutter/models/badge.dart'; // Adjust import path if necessary

class BadgesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'badges'; // Firestore collection name

  // Get all badges
  Stream<List<Badge>> getBadges() {
    return _firestore.collection(_collectionName).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Badge(
          name: doc['name'],
          description: doc['description'],
          isUnlocked: doc['isUnlocked'],
        );
      }).toList();
    });
  }

  // Add a new badge
  Future<void> addBadge(Badge badge) async {
    await _firestore.collection(_collectionName).add({
      'name': badge.name,
      'description': badge.description,
      'isUnlocked': badge.isUnlocked,
    });
  }

  // Update an existing badge
  Future<void> updateBadge(String badgeId, Badge updatedBadge) async {
    await _firestore.collection(_collectionName).doc(badgeId).update({
      'name': updatedBadge.name,
      'description': updatedBadge.description,
      'isUnlocked': updatedBadge.isUnlocked,
    });
  }

  // Delete a badge
  Future<void> deleteBadge(String badgeId) async {
    await _firestore.collection(_collectionName).doc(badgeId).delete();
  }

}

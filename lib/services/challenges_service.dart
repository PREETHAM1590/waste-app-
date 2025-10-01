import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:waste_classifier_flutter/models/challenge.dart'; // Adjust import path if necessary

class ChallengesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'challenges'; // Firestore collection name

  // Get all challenges
  Stream<List<Challenge>> getChallenges() {
    return _firestore.collection(_collectionName).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Challenge(
          name: doc['name'],
          description: doc['description'],
          isCompleted: doc['isCompleted'],
        );
      }).toList();
    });
  }

  // Add a new challenge
  Future<void> addChallenge(Challenge challenge) async {
    await _firestore.collection(_collectionName).add({
      'name': challenge.name,
      'description': challenge.description,
      'isCompleted': challenge.isCompleted,
    });
  }

  // Update an existing challenge
  Future<void> updateChallenge(String challengeId, Challenge updatedChallenge) async {
    await _firestore.collection(_collectionName).doc(challengeId).update({
      'name': updatedChallenge.name,
      'description': updatedChallenge.description,
      'isCompleted': updatedChallenge.isCompleted,
    });
  }

  // Delete a challenge
  Future<void> deleteChallenge(String challengeId) async {
    await _firestore.collection(_collectionName).doc(challengeId).delete();
  }
}

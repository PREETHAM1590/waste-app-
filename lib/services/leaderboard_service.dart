import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:waste_classifier_flutter/models/leaderboard_entry.dart'; // Adjust import path if necessary

class LeaderboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'leaderboardEntries'; // Firestore collection name

  // Get all leaderboard entries
  Stream<List<LeaderboardEntry>> getLeaderboardEntries() {
    return _firestore.collection(_collectionName).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return LeaderboardEntry(
          name: doc['name'],
          score: doc['score'],
        );
      }).toList();
    });
  }

  // Add a new leaderboard entry
  Future<void> addLeaderboardEntry(LeaderboardEntry entry) async {
    await _firestore.collection(_collectionName).add({
      'name': entry.name,
      'score': entry.score,
    });
  }

  // Update an existing leaderboard entry
  Future<void> updateLeaderboardEntry(String entryId, LeaderboardEntry updatedEntry) async {
    await _firestore.collection(_collectionName).doc(entryId).update({
      'name': updatedEntry.name,
      'score': updatedEntry.score,
    });
  }

  // Delete a leaderboard entry
  Future<void> deleteLeaderboardEntry(String entryId) async {
    await _firestore.collection(_collectionName).doc(entryId).delete();
  }
}

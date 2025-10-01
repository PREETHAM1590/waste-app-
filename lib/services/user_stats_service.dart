import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserStats {
  final int totalScans;
  final int ecoPoints;
  final int achievementsUnlocked;
  final int totalAchievements;
  final double carbonSaved; // in kg
  final Map<String, int> wasteTypeScans; // Count of each waste type scanned

  UserStats({
    this.totalScans = 0,
    this.ecoPoints = 0,
    this.achievementsUnlocked = 0,
    this.totalAchievements = 15,
    this.carbonSaved = 0.0,
    this.wasteTypeScans = const {},
  });

  factory UserStats.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserStats(
      totalScans: data['totalScans'] ?? 0,
      ecoPoints: data['ecoPoints'] ?? 0,
      achievementsUnlocked: data['achievementsUnlocked'] ?? 0,
      totalAchievements: data['totalAchievements'] ?? 15,
      carbonSaved: (data['carbonSaved'] ?? 0.0).toDouble(),
      wasteTypeScans: Map<String, int>.from(data['wasteTypeScans'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'totalScans': totalScans,
      'ecoPoints': ecoPoints,
      'achievementsUnlocked': achievementsUnlocked,
      'totalAchievements': totalAchievements,
      'carbonSaved': carbonSaved,
      'wasteTypeScans': wasteTypeScans,
      'lastUpdated': FieldValue.serverTimestamp(),
    };
  }

  UserStats copyWith({
    int? totalScans,
    int? ecoPoints,
    int? achievementsUnlocked,
    int? totalAchievements,
    double? carbonSaved,
    Map<String, int>? wasteTypeScans,
  }) {
    return UserStats(
      totalScans: totalScans ?? this.totalScans,
      ecoPoints: ecoPoints ?? this.ecoPoints,
      achievementsUnlocked: achievementsUnlocked ?? this.achievementsUnlocked,
      totalAchievements: totalAchievements ?? this.totalAchievements,
      carbonSaved: carbonSaved ?? this.carbonSaved,
      wasteTypeScans: wasteTypeScans ?? this.wasteTypeScans,
    );
  }

  double get achievementProgress => 
      totalAchievements > 0 ? achievementsUnlocked / totalAchievements : 0.0;
}

class UserStatsService {
  static final UserStatsService _instance = UserStatsService._internal();
  factory UserStatsService() => _instance;
  UserStatsService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user's stats
  Future<UserStats> getUserStats() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return UserStats();
      }

      final doc = await _firestore
          .collection('user_stats')
          .doc(user.uid)
          .get();

      if (!doc.exists) {
        // Create initial stats document
        final initialStats = UserStats();
        await _firestore
            .collection('user_stats')
            .doc(user.uid)
            .set(initialStats.toFirestore());
        return initialStats;
      }

      return UserStats.fromFirestore(doc);
    } catch (e) {
      print('Error fetching user stats: $e');
      return UserStats();
    }
  }

  /// Stream of user stats (real-time updates)
  Stream<UserStats> getUserStatsStream() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value(UserStats());
    }

    return _firestore
        .collection('user_stats')
        .doc(user.uid)
        .snapshots()
        .map((doc) {
      if (!doc.exists) {
        return UserStats();
      }
      return UserStats.fromFirestore(doc);
    });
  }

  /// Record a waste scan and update stats
  Future<void> recordScan({
    required String wasteType,
    int pointsEarned = 10,
    double carbonSaved = 0.5, // Average carbon saved per scan in kg
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final statsRef = _firestore.collection('user_stats').doc(user.uid);
      
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(statsRef);
        
        UserStats currentStats;
        if (!snapshot.exists) {
          currentStats = UserStats();
        } else {
          currentStats = UserStats.fromFirestore(snapshot);
        }

        // Update waste type count
        final updatedWasteTypeScans = Map<String, int>.from(currentStats.wasteTypeScans);
        updatedWasteTypeScans[wasteType] = (updatedWasteTypeScans[wasteType] ?? 0) + 1;

        // Create updated stats
        final updatedStats = currentStats.copyWith(
          totalScans: currentStats.totalScans + 1,
          ecoPoints: currentStats.ecoPoints + pointsEarned,
          carbonSaved: currentStats.carbonSaved + carbonSaved,
          wasteTypeScans: updatedWasteTypeScans,
        );

        transaction.set(statsRef, updatedStats.toFirestore());
      });

      // Check and award achievements based on milestones
      await _checkAndAwardAchievements();
    } catch (e) {
      print('Error recording scan: $e');
    }
  }

  /// Check and award achievements based on current stats
  Future<void> _checkAndAwardAchievements() async {
    try {
      final stats = await getUserStats();
      int newAchievements = 0;

      // Achievement milestones
      if (stats.totalScans >= 1) newAchievements++;
      if (stats.totalScans >= 10) newAchievements++;
      if (stats.totalScans >= 50) newAchievements++;
      if (stats.totalScans >= 100) newAchievements++;
      if (stats.ecoPoints >= 100) newAchievements++;
      if (stats.ecoPoints >= 500) newAchievements++;
      if (stats.ecoPoints >= 1000) newAchievements++;
      if (stats.carbonSaved >= 10) newAchievements++;
      if (stats.carbonSaved >= 50) newAchievements++;
      if (stats.wasteTypeScans.length >= 5) newAchievements++;

      // Update achievements if changed
      if (newAchievements != stats.achievementsUnlocked) {
        await _updateAchievements(newAchievements);
      }
    } catch (e) {
      print('Error checking achievements: $e');
    }
  }

  /// Update achievements count
  Future<void> _updateAchievements(int achievementsUnlocked) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore
          .collection('user_stats')
          .doc(user.uid)
          .update({
        'achievementsUnlocked': achievementsUnlocked,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating achievements: $e');
    }
  }

  /// Manually add eco-points (for challenges, etc.)
  Future<void> addEcoPoints(int points) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore
          .collection('user_stats')
          .doc(user.uid)
          .update({
        'ecoPoints': FieldValue.increment(points),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding eco-points: $e');
    }
  }

  /// Reset stats (for testing or user request)
  Future<void> resetStats() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore
          .collection('user_stats')
          .doc(user.uid)
          .set(UserStats().toFirestore());
    } catch (e) {
      print('Error resetting stats: $e');
    }
  }
}

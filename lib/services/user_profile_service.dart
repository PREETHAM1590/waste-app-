import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:waste_classifier_flutter/models/user_profile.dart';

class UserProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'user_profiles';

  // Create a new user profile
  Future<void> createUserProfile(UserProfile profile) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(profile.uid)
          .set(profile.toMap());
    } catch (e) {
      throw Exception('Failed to create user profile: ');
    }
  }

  // Get user profile by UID
  Future<UserProfile?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore
          .collection(_collection)
          .doc(uid)
          .get();

      if (doc.exists && doc.data() != null) {
        return UserProfile.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user profile: ');
    }
  }

  // Update user profile
  Future<void> updateUserProfile(UserProfile profile) async {
    try {
      final updatedProfile = profile.copyWith(updatedAt: DateTime.now());
      await _firestore
          .collection(_collection)
          .doc(profile.uid)
          .set(updatedProfile.toMap(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update user profile: ');
    }
  }

  // Check if user has completed onboarding
  Future<bool> hasCompletedOnboarding(String uid) async {
    try {
      final profile = await getUserProfile(uid);
      return profile?.onboardingCompleted ?? false;
    } catch (e) {
      // If there's an error getting the profile, assume onboarding is not completed
      return false;
    }
  }

  // Mark onboarding as completed
  Future<void> markOnboardingCompleted(String uid) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(uid)
          .update({
        'onboardingCompleted': true,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to mark onboarding as completed: ');
    }
  }

  // Delete user profile
  Future<void> deleteUserProfile(String uid) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(uid)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete user profile: ');
    }
  }

  // Stream user profile changes
  Stream<UserProfile?> getUserProfileStream(String uid) {
    return _firestore
        .collection(_collection)
        .doc(uid)
        .snapshots()
        .map((doc) {
      if (doc.exists && doc.data() != null) {
        return UserProfile.fromMap(doc.data()!);
      }
      return null;
    });
  }

  // Get public profiles (for community features)
  Future<List<UserProfile>> getPublicProfiles({
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query query = _firestore
          .collection(_collection)
          .where('publicProfile', isEqualTo: true)
          .orderBy('updatedAt', descending: true)
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final QuerySnapshot snapshot = await query.get();
      
      return snapshot.docs
          .map((doc) => UserProfile.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get public profiles: ');
    }
  }

  // Search users by name or interests
  Future<List<UserProfile>> searchUsers({
    String? nameQuery,
    List<String>? interests,
    int limit = 20,
  }) async {
    try {
      Query query = _firestore
          .collection(_collection)
          .where('publicProfile', isEqualTo: true);

      if (nameQuery != null && nameQuery.isNotEmpty) {
        // Note: Firestore doesn't support full-text search natively
        // This is a simple prefix search on fullName
        query = query
            .where('fullName', isGreaterThanOrEqualTo: nameQuery)
            .where('fullName', isLessThan: '$nameQuery\uf8ff');
      }

      if (interests != null && interests.isNotEmpty) {
        query = query.where('interests', arrayContainsAny: interests);
      }

      query = query.limit(limit);

      final QuerySnapshot snapshot = await query.get();
      
      return snapshot.docs
          .map((doc) => UserProfile.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to search users: ');
    }
  }

  // Update specific fields
  Future<void> updateProfileField(String uid, String field, dynamic value) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(uid)
          .update({
        field: value,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update profile field: ');
    }
  }

  // Batch update multiple fields
  Future<void> updateProfileFields(String uid, Map<String, dynamic> updates) async {
    try {
      final Map<String, dynamic> finalUpdates = {
        ...updates,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      await _firestore
          .collection(_collection)
          .doc(uid)
          .update(finalUpdates);
    } catch (e) {
      throw Exception('Failed to update profile fields: ');
    }
  }

  // Get users by interests (for community matching)
  Future<List<UserProfile>> getUsersByInterests(List<String> interests) async {
    if (interests.isEmpty) return [];

    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('publicProfile', isEqualTo: true)
          .where('interests', arrayContainsAny: interests)
          .limit(50)
          .get();

      return snapshot.docs
          .map((doc) => UserProfile.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get users by interests: ');
    }
  }

  // Analytics methods
  Future<Map<String, int>> getInterestStats() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('publicProfile', isEqualTo: true)
          .get();

      final Map<String, int> interestCounts = {};

      for (final doc in snapshot.docs) {
        final profile = UserProfile.fromMap(doc.data() as Map<String, dynamic>);
        for (final interest in profile.interests) {
          interestCounts[interest] = (interestCounts[interest] ?? 0) + 1;
        }
      }

      return interestCounts;
    } catch (e) {
      throw Exception('Failed to get interest stats: ');
    }
  }
}

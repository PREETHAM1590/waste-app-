import 'package:cloud_firestore/cloud_firestore.dart';

enum Gender {
  male,
  female,
  nonBinary,
  preferNotToSay,
}

class UserProfile {
  final String uid;
  final String email;
  final String fullName;
  final String? bio;
  final DateTime? dateOfBirth;
  final Gender gender;
  final String? location;
  final String? phoneNumber;
  final String? website;
  final String? profileImageUrl;
  final List<String> interests;
  final String preferredLanguage;
  final String preferredUnit;
  final bool publicProfile;
  final bool shareProgress;
  final bool emailNotifications;
  final bool onboardingCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.uid,
    required this.email,
    required this.fullName,
    this.bio,
    this.dateOfBirth,
    this.gender = Gender.preferNotToSay,
    this.location,
    this.phoneNumber,
    this.website,
    this.profileImageUrl,
    this.interests = const [],
    this.preferredLanguage = 'en',
    this.preferredUnit = 'metric',
    this.publicProfile = true,
    this.shareProgress = true,
    this.emailNotifications = true,
    this.onboardingCompleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert UserProfile to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'bio': bio,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender.name,
      'location': location,
      'phoneNumber': phoneNumber,
      'website': website,
      'profileImageUrl': profileImageUrl,
      'interests': interests,
      'preferredLanguage': preferredLanguage,
      'preferredUnit': preferredUnit,
      'publicProfile': publicProfile,
      'shareProgress': shareProgress,
      'emailNotifications': emailNotifications,
      'onboardingCompleted': onboardingCompleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create UserProfile from Firestore document
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      fullName: map['fullName'] ?? '',
      bio: map['bio'],
      dateOfBirth: map['dateOfBirth'] != null 
          ? DateTime.tryParse(map['dateOfBirth'])
          : null,
      gender: Gender.values.firstWhere(
        (e) => e.name == map['gender'],
        orElse: () => Gender.preferNotToSay,
      ),
      location: map['location'],
      phoneNumber: map['phoneNumber'],
      website: map['website'],
      profileImageUrl: map['profileImageUrl'],
      interests: List<String>.from(map['interests'] ?? []),
      preferredLanguage: map['preferredLanguage'] ?? 'en',
      preferredUnit: map['preferredUnit'] ?? 'metric',
      publicProfile: map['publicProfile'] ?? true,
      shareProgress: map['shareProgress'] ?? true,
      emailNotifications: map['emailNotifications'] ?? true,
      onboardingCompleted: map['onboardingCompleted'] ?? false,
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  // Create UserProfile from Firestore DocumentSnapshot
  factory UserProfile.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile.fromMap(data);
  }

  // Create a copy of the UserProfile with updated fields
  UserProfile copyWith({
    String? uid,
    String? email,
    String? fullName,
    String? bio,
    DateTime? dateOfBirth,
    Gender? gender,
    String? location,
    String? phoneNumber,
    String? website,
    String? profileImageUrl,
    List<String>? interests,
    String? preferredLanguage,
    String? preferredUnit,
    bool? publicProfile,
    bool? shareProgress,
    bool? emailNotifications,
    bool? onboardingCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      bio: bio ?? this.bio,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      location: location ?? this.location,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      website: website ?? this.website,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      interests: interests ?? this.interests,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      preferredUnit: preferredUnit ?? this.preferredUnit,
      publicProfile: publicProfile ?? this.publicProfile,
      shareProgress: shareProgress ?? this.shareProgress,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserProfile(uid: , email: , fullName: , onboardingCompleted: )';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';

/// Firebase Authentication Service
/// Handles user authentication using Firebase Auth
class FirebaseAuthService {
  static final FirebaseAuthService _instance = FirebaseAuthService._internal();
  factory FirebaseAuthService() => _instance;
  FirebaseAuthService._internal();
  
  // Lazy getter for FirebaseAuth to avoid accessing it before Firebase.initializeApp()
  FirebaseAuth? _authInstance;
  FirebaseAuth get _auth {
    try {
      _authInstance ??= FirebaseAuth.instance;
      return _authInstance!;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Firebase not initialized yet: $e');
      }
      rethrow;
    }
  }
  
  /// Check if Firebase is available
  bool get isFirebaseAvailable {
    try {
      FirebaseAuth.instance;
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// Current Firebase user stream
  Stream<User?> get authStateChanges {
    if (!isFirebaseAvailable) {
      return Stream.value(null);
    }
    return _auth.authStateChanges();
  }
  
  /// Current user
  User? get currentUser {
    if (!isFirebaseAvailable) {
      return null;
    }
    return _auth.currentUser;
  }
  
  /// Check if user is currently signed in
  bool get isSignedIn => currentUser != null;
  
  /// Sign in with email and password
  Future<UserProfile?> signInWithEmailAndPassword(String email, String password) async {
    try {
      if (kDebugMode) {
        debugPrint('Signing in with email: $email');
      }
      
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final User? user = userCredential.user;
      
      if (user != null) {
        if (kDebugMode) {
          debugPrint('Successfully signed in with email: ${user.email}');
        }
        
        return UserProfile(
          uid: user.uid,
          fullName: user.displayName ?? email.split('@')[0],
          email: user.email ?? email,
          bio: 'Firebase user',
          profileImageUrl: user.photoURL,
          createdAt: user.metadata.creationTime ?? DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }
      
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error signing in with email and password: $e');
      }
      rethrow;
    }
  }
  
  /// Create account with email and password
  Future<UserProfile?> createUserWithEmailAndPassword(
    String name,
    String email, 
    String password,
  ) async {
    try {
      if (kDebugMode) {
        debugPrint('Creating user with email: $email');
      }
      
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final User? user = userCredential.user;
      
      if (user != null) {
        // Update the user's display name
        await user.updateDisplayName(name);
        await user.reload();
        
        if (kDebugMode) {
          debugPrint('Successfully created user: ${user.email}');
        }
        
        return UserProfile(
          uid: user.uid,
          fullName: name,
          email: user.email ?? email,
          bio: 'New to Waste Wise!',
          profileImageUrl: user.photoURL,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }
      
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error creating user with email and password: $e');
      }
      rethrow;
    }
  }
  
  /// Sign out
  Future<void> signOut() async {
    try {
      if (kDebugMode) {
        debugPrint('Signing out user...');
      }
      
      // Sign out from Firebase
      await _auth.signOut();
      
      if (kDebugMode) {
        debugPrint('User signed out successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error signing out: $e');
      }
      rethrow;
    }
  }
  
  /// Reset password
  Future<void> resetPassword(String email) async {
    try {
      if (kDebugMode) {
        debugPrint('Sending password reset email to: $email');
      }
      
      await _auth.sendPasswordResetEmail(email: email);
      
      if (kDebugMode) {
        debugPrint('Password reset email sent successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error sending password reset email: $e');
      }
      rethrow;
    }
  }
  
  /// Delete user account
  Future<void> deleteUser() async {
    try {
      final user = currentUser;
      if (user != null) {
        if (kDebugMode) {
          debugPrint('Deleting user account: ${user.email}');
        }
        
        await user.delete();
        
        if (kDebugMode) {
          debugPrint('User account deleted successfully');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error deleting user account: $e');
      }
      rethrow;
    }
  }
  
  /// Get current user as UserProfile
  UserProfile? getCurrentUserProfile() {
    final user = currentUser;
    if (user != null) {
      return UserProfile(
        uid: user.uid,
        fullName: user.displayName ?? 'Firebase User',
        email: user.email ?? '',
        bio: 'Firebase authenticated user',
        profileImageUrl: user.photoURL,
        createdAt: user.metadata.creationTime ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
    return null;
  }
}
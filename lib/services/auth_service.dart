import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:waste_classifier_flutter/wallet/services/wallet_service.dart'; // Import WalletService

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Web OAuth Client ID for Web3Auth integration
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final WalletService _walletService = WalletService.instance; // Use WalletService
  bool _isInitialized = false;
  GoogleSignInAccount? _currentUser;

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await _googleSignIn.initialize(
        serverClientId: '505915447559-3gpaa7j6i148sovv9annkb807j2a07bu.apps.googleusercontent.com',
      );
      _googleSignIn.authenticationEvents.listen(_handleAuthenticationEvent);
      _isInitialized = true;
    }
  }

  void _handleAuthenticationEvent(GoogleSignInAuthenticationEvent event) {
    switch (event) {
      case GoogleSignInAuthenticationEventSignIn():
        _currentUser = event.user;
        break;
      case GoogleSignInAuthenticationEventSignOut():
        _currentUser = null;
        break;
    }
  }

  Future<Map<String, dynamic>> signInWithGoogleAndWeb3() async {
    try {
      await _ensureInitialized();
      
      // 1. Check if already signed in
      if (_currentUser == null) {
        if (_googleSignIn.supportsAuthenticate()) {
          await _googleSignIn.authenticate();
        } else {
          return {'success': false, 'message': 'Platform does not support authentication'};
        }
        
        // Wait a bit for the authentication event to be processed
        await Future.delayed(const Duration(milliseconds: 500));
      }

      if (_currentUser == null) {
        return {'success': false, 'message': 'Google sign-in failed or cancelled'};
      }

      // 2. Get authorization for Firebase scopes
      const scopes = ['openid', 'profile', 'email'];
      GoogleSignInClientAuthorization? authorization = 
          await _currentUser!.authorizationClient.authorizationForScopes(scopes);

      authorization ??= await _currentUser!.authorizationClient.authorizeScopes(scopes);


      // 3. Get authentication tokens (including idToken)
      final GoogleSignInAuthentication authentication = _currentUser!.authentication;
      
      // Sign in to Firebase with Google credentials
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: authorization.accessToken,
        idToken: authentication.idToken,
      );
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        return {'success': false, 'message': 'Firebase sign-in failed'};
      }

      // Check if idToken is available before proceeding to Web3Auth
      if (authentication.idToken == null) {
        return {'success': false, 'message': 'Google ID Token not obtained. Cannot proceed with Web3Auth login'};
      }

      // 4. Use Web3Auth login with Google
      final success = await _walletService.loginWithGoogle();

      if (success) {
        return {
          'success': true,
          'firebaseUser': firebaseUser,
          'web3UserInfo': _walletService.state.userInfo,
          'walletAddress': _walletService.state.walletAddress,
        };
      } else {
        // If Web3Auth fails, you might want to sign out from Firebase too
        await _auth.signOut();
        return {'success': false, 'message': _walletService.state.error ?? 'Web3Auth login failed.'};
      }
    } catch (e) {
      // Log error for debugging only in debug mode
      if (kDebugMode) {
        debugPrint("Error during Google and Web3 login: $e");
      }
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<void> signOut() async {
    await _ensureInitialized();
    await _googleSignIn.signOut();
    await _auth.signOut();
    await _walletService.logout(); // Also logout from WalletService
  }
}

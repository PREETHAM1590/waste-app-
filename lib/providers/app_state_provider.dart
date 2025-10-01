import 'package:flutter/foundation.dart';
import 'dart:convert';
import '../models/user_profile.dart';
import '../services/firebase_auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../wallet/services/wallet_service.dart'; // Import the new WalletService

/// Global app state provider managing authentication and user data
class AppStateProvider extends ChangeNotifier {
  // User authentication state
  bool _isAuthenticated = false; // Start as false, check wallet state on init
  bool _isLoading = false;
  UserProfile? _currentUser;
  
  // Services
  final WalletService _walletService = WalletService.instance; // Use the new WalletService
  final FirebaseAuthService _firebaseService = FirebaseAuthService();
  
  // Storage keys
  static const String _keyAppIsAuthenticated = 'app_is_authenticated';
  static const String _keyAppCurrentUser = 'app_current_user';
  
  // App configuration state
  bool _isFirstLaunch = true;
  bool _hasCompletedOnboarding = false;
  String? _errorMessage;

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  UserProfile? get currentUser => _currentUser;
  bool get isFirstLaunch => _isFirstLaunch;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;
  String? get errorMessage => _errorMessage;
  
  // Initialize authentication state from both services
  Future<void> initializeAuthenticationState() async {
    setLoading(true);
    
    try {
      // First, check Firebase Auth state (only if Firebase is available)
      if (_firebaseService.isFirebaseAvailable) {
        final firebaseUser = _firebaseService.currentUser;
        if (firebaseUser != null) {
          if (kDebugMode) {
            debugPrint('Found Firebase user: ${firebaseUser.email}');
          }
          
          final user = UserProfile(
            uid: firebaseUser.uid,
            fullName: firebaseUser.displayName ?? 'Firebase User',
            email: firebaseUser.email ?? '',
            bio: 'Authenticated with Firebase',
            profileImageUrl: firebaseUser.photoURL,
            createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
            updatedAt: DateTime.now(),
          );
          
          await _setUserWithPersistence(user, 'firebase');
          setLoading(false);
          return;
        }
      } else if (kDebugMode) {
        debugPrint('Firebase not yet initialized, skipping Firebase auth check');
      }
      
      // If no Firebase user, check wallet service
      final isWalletLoggedIn = _walletService.state.isLoggedIn; // Use WalletService state
      
      if (isWalletLoggedIn) {
        // Get wallet user info
        final userInfo = _walletService.state.userInfo; // Use WalletService state
        final walletAddress = _walletService.state.walletAddress; // Use WalletService state
        
        if (userInfo != null && walletAddress != null) {
          // Create user profile from wallet data
          final user = UserProfile(
            uid: 'wallet-${walletAddress.substring(0, 8)}', // Use wallet prefix as UID
            fullName: userInfo['name'] ?? 'Wallet User',
            email: userInfo['email'] ?? '',
            bio: 'Wallet: ${walletAddress.substring(0, 6)}...${walletAddress.substring(walletAddress.length - 4)}',
            createdAt: DateTime.now().subtract(const Duration(days: 7)), // Default creation time
            updatedAt: DateTime.now(),
          );
          
          await _setUserWithPersistence(user, 'wallet');
        }
      } else {
        // Check if we have stored authentication state
        await _loadStoredAuthState();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error initializing authentication state: $e');
      }
      // Fallback to checking stored state
      await _loadStoredAuthState();
    } finally {
      setLoading(false);
    }
  }
  
  // Load stored authentication state
  Future<void> _loadStoredAuthState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isAuthenticated = prefs.getBool(_keyAppIsAuthenticated) ?? false;
      
      final userJson = prefs.getString(_keyAppCurrentUser);
      if (userJson != null && _isAuthenticated) {
        final userData = jsonDecode(userJson) as Map<String, dynamic>;
        _currentUser = UserProfile.fromMap(userData);
      }
      
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading stored auth state: $e');
      }
      _isAuthenticated = false;
      _currentUser = null;
      notifyListeners();
    }
  }
  
  // Set user with persistence
  Future<void> _setUserWithPersistence(UserProfile user, String authMethod) async {
    _currentUser = user;
    _isAuthenticated = true;
    
    // Store in SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyAppIsAuthenticated, true);
      await prefs.setString(_keyAppCurrentUser, jsonEncode(user.toMap()));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error persisting user data: $e');
      }
    }
    
    notifyListeners();
  }
  
  // User state management
  void setUser(UserProfile user) {
    _currentUser = user;
    _isAuthenticated = true;
    notifyListeners();
  }
  
  Future<void> clearUser() async {
    _currentUser = null;
    _isAuthenticated = false;
    
    // Clear persistent storage
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyAppIsAuthenticated);
      await prefs.remove(_keyAppCurrentUser);
      
      // Also logout from wallet service
      await _walletService.logout(); // Use WalletService logout
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error clearing user data: $e');
      }
    }
    
    notifyListeners();
  }
  
  void updateUserProfile(UserProfile updatedUser) {
    _currentUser = updatedUser;
    notifyListeners();
  }
  
  // Loading state management
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  // App configuration management
  void completeOnboarding() {
    _hasCompletedOnboarding = true;
    _isFirstLaunch = false;
    notifyListeners();
  }
  
  void setFirstLaunchCompleted() {
    _isFirstLaunch = false;
    notifyListeners();
  }
  
  // Error handling
  void setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }
  
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
  
  // Wallet authentication method
  Future<bool> authenticateWithWallet(String email) async {
    setLoading(true);
    clearError();
    
    try {
      // Use wallet service to login with email
      final success = await _walletService.loginWithEmail(email); // Use WalletService login
      
      if (success) {
        final userInfo = _walletService.state.userInfo; // Use WalletService state
        final walletAddress = _walletService.state.walletAddress; // Use WalletService state
        
        if (userInfo != null && walletAddress != null) {
          // Create user profile from wallet data
          final user = UserProfile(
            uid: 'wallet-${walletAddress.substring(0, 8)}',
            fullName: userInfo['name'] ?? email.split('@')[0],
            email: userInfo['email'] ?? email,
            bio: 'Wallet: ${walletAddress.substring(0, 6)}...${walletAddress.substring(walletAddress.length - 4)}',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          
          await _setUserWithPersistence(user, 'wallet');
          return true;
        } else {
          setError('Failed to get wallet info after login');
          return false;
        }
      } else {
        setError('Failed to authenticate with wallet: ${_walletService.state.error ?? 'Unknown error'}');
        return false;
      }
    } catch (e) {
      setError('Wallet authentication error: ${e.toString()}');
      return false;
    } finally {
      setLoading(false);
    }
  }
  
  // Authentication methods
  Future<void> signIn(String email, String password) async {
    setLoading(true);
    clearError();
    
    try {
      // Check if Firebase is available
      if (!_firebaseService.isFirebaseAvailable) {
        setError('Firebase authentication is not available. Please try again later.');
        return;
      }
      
      // Try Firebase authentication
      final userProfile = await _firebaseService.signInWithEmailAndPassword(email, password);
      
      if (userProfile != null) {
        await _setUserWithPersistence(userProfile, 'firebase');
      } else {
        setError('Failed to sign in with email and password');
      }
    } catch (e) {
      setError('Failed to sign in: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }
  
  Future<void> signUp(String name, String email, String password) async {
    setLoading(true);
    clearError();
    
    try {
      // Check if Firebase is available
      if (!_firebaseService.isFirebaseAvailable) {
        setError('Firebase authentication is not available. Please try again later.');
        return;
      }
      
      // Create Firebase account
      final userProfile = await _firebaseService.createUserWithEmailAndPassword(name, email, password);
      
      if (userProfile != null) {
        await _setUserWithPersistence(userProfile, 'firebase');
      } else {
        setError('Failed to create account');
      }
    } catch (e) {
      setError('Failed to create account: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }
  
  Future<void> signOut() async {
    setLoading(true);
    
    try {
      // Sign out from both services (if available)
      if (_firebaseService.isFirebaseAvailable) {
        await _firebaseService.signOut();
      }
      await _walletService.logout();
      await clearUser();
    } catch (e) {
      setError('Failed to sign out: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }
  
  // User stats updates (called after scanning, challenges, etc.)
  // TODO: Implement with proper gamification model
  void updateUserStats() {
    // Placeholder for user stats updates
    notifyListeners();
  }
}

/// Provider for managing navigation state and bottom nav selection
class NavigationProvider extends ChangeNotifier {
  int _selectedIndex = 0;
  
  int get selectedIndex => _selectedIndex;
  
  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }
  
  // Navigation helper methods
  void navigateToHome() => setSelectedIndex(0);
  void navigateToStats() => setSelectedIndex(1);
  void navigateToCommunity() => setSelectedIndex(2);
  void navigateToProfile() => setSelectedIndex(3);
}

/// Provider for managing app-wide UI state
class UIStateProvider extends ChangeNotifier {
  bool _showBottomSheet = false;
  bool _isKeyboardVisible = false;
  String? _activeBottomSheetType;
  
  // Getters
  bool get showBottomSheet => _showBottomSheet;
  bool get isKeyboardVisible => _isKeyboardVisible;
  String? get activeBottomSheetType => _activeBottomSheetType;
  
  // Bottom sheet management
  void showBottomSheetOfType(String type) {
    _activeBottomSheetType = type;
    _showBottomSheet = true;
    notifyListeners();
  }
  
  void hideBottomSheet() {
    _showBottomSheet = false;
    _activeBottomSheetType = null;
    notifyListeners();
  }
  
  // Keyboard visibility
  void setKeyboardVisibility(bool visible) {
    _isKeyboardVisible = visible;
    notifyListeners();
  }
}

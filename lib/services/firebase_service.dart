import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import '../firebase_options.dart';

/// Firebase service with retry logic and better error handling
class FirebaseService {
  static FirebaseService? _instance;
  static FirebaseService get instance => _instance ??= FirebaseService._internal();
  FirebaseService._internal();

  bool _isInitialized = false;
  bool _isInitializing = false;
  
  bool get isInitialized => _isInitialized;
  
  /// Initialize Firebase with retry logic
  Future<bool> initialize({int maxRetries = 3}) async {
    if (_isInitialized) {
      if (kDebugMode) {
        debugPrint('Firebase already initialized');
      }
      return true;
    }
    
    if (_isInitializing) {
      if (kDebugMode) {
        debugPrint('Firebase initialization already in progress');
      }
      return false;
    }
    
    _isInitializing = true;
    
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        if (kDebugMode) {
          debugPrint('🔥 Initializing Firebase (attempt $attempt/$maxRetries)...');
        }
        
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        
        // Set up error handling
        FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
        
        _isInitialized = true;
        _isInitializing = false;
        
        if (kDebugMode) {
          debugPrint('✅ Firebase initialized successfully');
        }
        
        return true;
      } catch (e) {
        if (kDebugMode) {
          debugPrint('❌ Firebase initialization failed (attempt $attempt/$maxRetries): $e');
        }
        
        // If this is the last attempt, give up
        if (attempt == maxRetries) {
          _isInitializing = false;
          
          // Set up basic error handling without Firebase
          FlutterError.onError = (FlutterErrorDetails details) {
            if (kDebugMode) {
              debugPrint('Flutter Error: ${details.exception}');
              debugPrint('Stack: ${details.stack}');
            }
          };
          
          if (kDebugMode) {
            debugPrint('❌ Firebase initialization failed after $maxRetries attempts. Continuing without Firebase...');
          }
          
          return false;
        }
        
        // Wait before retrying (exponential backoff)
        await Future.delayed(Duration(seconds: attempt * 2));
      }
    }
    
    _isInitializing = false;
    return false;
  }
  
  /// Record error to Crashlytics if available
  void recordError(dynamic error, StackTrace? stack, {bool fatal = false}) {
    if (!_isInitialized) {
      if (kDebugMode) {
        debugPrint('Firebase not initialized, logging error locally: $error');
      }
      return;
    }
    
    try {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: fatal);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to record error to Crashlytics: $e');
      }
    }
  }
  
  /// Set custom key for error reporting
  void setCustomKey(String key, Object value) {
    if (!_isInitialized) return;
    
    try {
      FirebaseCrashlytics.instance.setCustomKey(key, value);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to set custom key: $e');
      }
    }
  }
  
  /// Set user identifier for error reporting
  void setUserId(String userId) {
    if (!_isInitialized) return;
    
    try {
      FirebaseCrashlytics.instance.setUserIdentifier(userId);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to set user ID: $e');
      }
    }
  }
  
  /// Log message for debugging
  void log(String message) {
    if (!_isInitialized) {
      if (kDebugMode) {
        debugPrint('Firebase log: $message');
      }
      return;
    }
    
    try {
      FirebaseCrashlytics.instance.log(message);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to log to Firebase: $e');
      }
    }
  }
}
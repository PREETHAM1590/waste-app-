import 'package:waste_classifier_flutter/core/solana/solana_provider.dart';
import 'package:get_it/get_it.dart';
import 'package:solana/solana.dart';
import 'package:waste_classifier_flutter/config/network_config.dart';
import 'package:flutter/foundation.dart';

class ServiceLocator {
  ServiceLocator._();

  static GetIt get getIt => GetIt.instance;
  static bool _isInitialized = false;
  static bool _isInitializing = false;
  static final List<Future<void>> _pendingInitializations = [];

  static Future<void> init() async {
    // Check if already properly initialized (fast path)
    if (_isInitialized && getIt.isRegistered<SolanaClient>()) {
      if (kDebugMode) {
        debugPrint('ServiceLocator already initialized and services registered');
      }
      return;
    }
    
    // If initialization is in progress, wait for it
    if (_isInitializing) {
      if (kDebugMode) {
        debugPrint('ServiceLocator initialization already in progress, waiting...');
      }
      // Wait for current initialization to complete
      while (_isInitializing) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
      // After waiting, check again if services are registered
      if (getIt.isRegistered<SolanaClient>()) {
        if (kDebugMode) {
          debugPrint('ServiceLocator initialization completed by another caller');
        }
        return;
      }
    }
    
    // Set flag atomically
    if (_isInitializing) {
      // Double-check: Another thread beat us to it
      return;
    }
    _isInitializing = true;
    
    try {
      // Handle hot reload case - if services exist but flag is wrong
      if (getIt.isRegistered<SolanaClient>()) {
        if (kDebugMode) {
          debugPrint('SolanaClient already registered (hot reload scenario), marking as initialized');
        }
        _isInitialized = true;
        _isInitializing = false;
        return;
      }

      if (kDebugMode) {
        debugPrint('🔧 Initializing ServiceLocator...');
      }

      final solanaClient = SolanaClient(
        rpcUrl: Uri.parse(SolanaNetworkConfig.rpcUrl),
        websocketUrl: Uri.parse(SolanaNetworkConfig.wsUrl),
      );

      // Only register if not already registered
      if (!getIt.isRegistered<SolanaClient>()) {
        getIt.registerLazySingleton<SolanaClient>(() => solanaClient);
      }
      
      // Only register SolanaProvider if not already registered
      if (!getIt.isRegistered<SolanaProvider>()) {
        getIt.registerLazySingleton(() => SolanaProvider(getIt()));
      }
      
      _isInitialized = true;
      
      if (kDebugMode) {
        debugPrint('✅ ServiceLocator initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ ServiceLocator initialization failed: $e');
      }
      
      // Handle specific registration errors more gracefully
      if (e.toString().contains('already registered')) {
        if (kDebugMode) {
          debugPrint('🔄 Services already registered, marking as initialized');
        }
        _isInitialized = true;
      } else {
        // For other errors, don't mark as initialized
        _isInitialized = false;
        if (kDebugMode) {
          debugPrint('⚠️ ServiceLocator will continue with limited functionality');
        }
      }
    } finally {
      _isInitializing = false;
    }
  }

  /// Reset the service locator (useful for testing)
  static Future<void> reset() async {
    await getIt.reset();
    _isInitialized = false;
  }

  /// Check if a service is registered
  static bool isRegistered<T extends Object>() {
    return getIt.isRegistered<T>();
  }
}

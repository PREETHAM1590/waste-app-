import 'package:flutter/material.dart';
import 'dart:async'; // Required for runZonedGuarded
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart' as flutter_provider;
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart'; // Import Crashlytics
import 'firebase_options.dart'; // Assuming this file will be generated
import 'services/firebase_service.dart'; // Import Firebase service

// Web3Auth imports
import 'package:web3auth_flutter/web3auth_flutter.dart';
import 'package:web3auth_flutter/input.dart';
import 'wallet/services/web3auth_config.dart'; // Use the consolidated Web3Auth config

// Core imports
import 'core/app_router.dart';
import 'core/service_locator.dart';
import 'wallet/services/wallet_service.dart';
import 'providers/theme_provider.dart';
import 'providers/chatbot_provider.dart';
import 'providers/app_state_provider.dart' as app_state_providers; // Import AppStateProvider with a prefix
import 'services/classification_service.dart'; // Import ClassificationService

void main() {
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Initialize Firebase with retry logic in the background
    // Don't block app startup for Firebase initialization
    FirebaseService.instance.initialize().then((success) {
      if (kDebugMode) {
        debugPrint('Firebase initialization completed: $success');
      }
    }).catchError((error) {
      if (kDebugMode) {
        debugPrint('Firebase initialization failed: $error');
      }
    });

    runApp(
      flutter_provider.MultiProvider(
        providers: [
          flutter_provider.ChangeNotifierProvider(create: (context) => ThemeProvider()),
          flutter_provider.ChangeNotifierProvider(create: (context) => ChatbotProvider()),
          flutter_provider.ChangeNotifierProvider(create: (context) => app_state_providers.AppStateProvider()),
          flutter_provider.ChangeNotifierProvider(create: (context) => app_state_providers.NavigationProvider()),
        ],
        child: const MyApp(),
      ),
    );
    
    // Initialize heavy services asynchronously after app starts
    // This will be handled by MyAppState._performInitialization()
  }, (error, stack) {
    // Catch all uncaught "non-fatal" errors from the Dart side.
    if (kDebugMode) {
      debugPrint('Uncaught error: $error');
      debugPrint('Stack: $stack');
    }
    
    // Record error using FirebaseService (handles availability automatically)
    FirebaseService.instance.recordError(error, stack, fatal: false);
  });
}

// Recommendation: Use Flutter DevTools for performance monitoring during development.
// Run `flutter run --profile` and open DevTools to analyze UI performance,
// widget rebuilds, and network activity.

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _loading = true;
  String? _initializationError;
  String _loadingMessage = 'Initializing app...';
  bool _isInitializing = false;

  @override
  void initState() {
    super.initState();
    _performInitialization();
  }

  Future<void> _performInitialization() async {
    // Prevent multiple simultaneous initializations
    if (_isInitializing) {
      if (kDebugMode) {
        debugPrint('Initialization already in progress, skipping...');
      }
      return;
    }
    
    _isInitializing = true;
    
    // Initialize authentication state asynchronously to avoid UI blocking
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final appStateProvider = flutter_provider.Provider.of<app_state_providers.AppStateProvider>(context, listen: false);
      // Run authentication initialization in background without awaiting
      appStateProvider.initializeAuthenticationState().catchError((error) {
        if (kDebugMode) {
          debugPrint('Authentication initialization error: $error');
        }
      });
    });

    try {
      // Update loading message
      if (mounted) {
        setState(() {
          _loadingMessage = 'Setting up core services...';
        });
      }
      
      // Initialize services in background threads to avoid blocking UI
      final List<Future> initializationFutures = [];
      
      // Initialize ServiceLocator (Solana services) in background
      initializationFutures.add(
        ServiceLocator.init().catchError((error) {
          if (kDebugMode) {
            debugPrint('ServiceLocator initialization failed: $error');
          }
        })
      );
      
      // Initialize ClassificationService model in background
      initializationFutures.add(
        ClassificationService().loadModel().catchError((error) {
          if (kDebugMode) {
            debugPrint('ClassificationService initialization failed: $error');
          }
        })
      );
      
      // Wait for critical services with a timeout to prevent indefinite blocking
      await Future.wait(initializationFutures).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          if (kDebugMode) {
            debugPrint('⚠️ Service initialization timed out, continuing with limited features');
          }
          return [];
        },
      );
      
      // Wallet service will initialize on-demand when user accesses wallet
      // No need to block app startup for wallet initialization
      if (kDebugMode) {
        debugPrint('Wallet service will initialize on-demand');
      }
      
      // Final loading message
      if (mounted) {
        setState(() {
          _loadingMessage = 'Finalizing setup...';
        });
      }
      
      if (kDebugMode) {
        debugPrint('✅ All services initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        // Only log as error if it's not a GetIt registration issue
        if (!e.toString().contains('already registered')) {
          debugPrint('Services initialization failed: $e');
          debugPrint('Some features may be limited until services are properly initialized');
        } else {
          debugPrint('Service registration conflict (hot reload): $e');
        }
      }
      
      // Only show error UI for truly critical failures
      if (e.toString().contains('ClassificationService') && !e.toString().contains('already registered')) {
        if (mounted) {
          setState(() {
            _initializationError = 'Failed to initialize critical services: ${e.toString()}';
          });
        }
        return;
      }
      
      // For GetIt registration errors, just continue - the app can still function
    } finally {
      _isInitializing = false;
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFF4CAF50),
        ),
        home: Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF4CAF50).withOpacity(0.05),
                  const Color(0xFF8BC34A).withOpacity(0.05),
                ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Material 3 CircularProgressIndicator
                  const SizedBox(
                    width: 56,
                    height: 56,
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    _loadingMessage,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.15,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Please wait while we set up your app',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[600],
                      letterSpacing: 0.25,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (_initializationError != null) {
      return MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFF4CAF50),
        ),
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Material 3 error icon in a container
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.error_outline_rounded,
                      color: Colors.red.shade700,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Initialization Error',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _initializationError!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[700],
                      letterSpacing: 0.25,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Material 3 FilledButton
                  FilledButton.icon(
                    onPressed: () {
                      setState(() {
                        _loading = true;
                        _initializationError = null;
                      });
                      _performInitialization();
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Retry'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        return flutter_provider.Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return MaterialApp.router(
              title: 'Waste Wise',
              themeMode: themeProvider.themeMode,
              theme: themeProvider.getLightTheme(lightDynamic),
              darkTheme: themeProvider.getDarkTheme(darkDynamic),
              routerConfig: AppRouter.createRouter(),
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('en', ''), // English
                // Add other supported locales here
              ],
            );
          },
        );
      },
    );
  }
}

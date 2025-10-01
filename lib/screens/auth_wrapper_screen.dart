import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:waste_classifier_flutter/wallet/services/wallet_service.dart';
import 'package:waste_classifier_flutter/providers/app_state_provider.dart';
import 'package:waste_classifier_flutter/screens/welcome_screen.dart';

class AuthWrapperScreen extends StatefulWidget {
  final String? deepLink;
  const AuthWrapperScreen({super.key, this.deepLink});

  @override
  State<AuthWrapperScreen> createState() => _AuthWrapperScreenState();
}

class _AuthWrapperScreenState extends State<AuthWrapperScreen> {
  bool _isChecking = true;
  bool _hasWeb3AuthSession = false;
  bool _hasAppSession = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final walletService = WalletService.instance;
      bool hasWeb3Session = false;

      if (widget.deepLink != null) {
        // Deep link provided - Web3Auth should handle it automatically
        debugPrint('Deep link received: ${widget.deepLink}');
      }
      
      // Check Web3Auth session (works with or without deep link)
      hasWeb3Session = await walletService.initialize();
      
      // Check app authentication state
      final appStateProvider = Provider.of<AppStateProvider>(context, listen: false);
      await appStateProvider.initializeAuthenticationState();
      
      setState(() {
        _hasWeb3AuthSession = hasWeb3Session;
        _hasAppSession = appStateProvider.isAuthenticated;
        _isChecking = false;
      });
      
      // Auto-navigate based on session state
      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 100)); // Minimal delay
        _navigateBasedOnAuth();
      }
    } catch (e) {
      debugPrint('Error checking auth status: $e');
      setState(() {
        _isChecking = false;
        _hasWeb3AuthSession = false;
        _hasAppSession = false;
      });
    }
  }

  void _navigateBasedOnAuth() {
    if (!mounted) return;
    
    if (_hasWeb3AuthSession || _hasAppSession) {
      // User has session, go to main app (wallet accessible via tab)
      context.go('/main/home');
    }
    // If no session, stay on current screen (welcome will be shown)
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      // Show minimal loading indicator
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).primaryColor,
          ),
        ),
      );
    }

    // Show welcome screen by default
    // Auto-navigation will happen after auth check
    return const WelcomeScreen();
  }
}

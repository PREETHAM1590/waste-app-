import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../wallet/services/wallet_service.dart';

/// Main wallet section that determines whether to show login or home
class WalletSectionScreen extends StatefulWidget {
  const WalletSectionScreen({super.key});

  @override
  State<WalletSectionScreen> createState() => _WalletSectionScreenState();
}

class _WalletSectionScreenState extends State<WalletSectionScreen> {
  late WalletService _walletService;
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _walletService = WalletService.instance;
    _checkWalletStatus();
  }

  Future<void> _checkWalletStatus() async {
    try {
      // Initialize wallet service if not already done
      if (!_walletService.state.isInitialized) {
        await _walletService.initialize();
      }
      
      // Check if user is logged in
      final isLoggedIn = await _walletService.checkLoginStatus();
      
      setState(() {
        _isLoggedIn = isLoggedIn;
        _isLoading = false;
      });
      
      // Navigate to appropriate screen
      if (mounted) {
        if (isLoggedIn) {
          context.go('/wallet-home');
        } else {
          context.go('/login');  // Use unified login
        }
      }
    } catch (e) {
      setState(() {
        _isLoggedIn = false;
        _isLoading = false;
      });
      
      if (mounted) {
        context.go('/login');  // Use unified login
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Wallet logo/icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[400]!, Colors.blue[600]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.account_balance_wallet,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            
            // Loading indicator
            if (_isLoading) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Initializing wallet...',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ] else ...[
              // If not loading and not logged in, show manual navigation
              if (!_isLoggedIn) ...[
                const Text(
                  'Wallet Ready',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.go('/login'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Access Wallet'),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
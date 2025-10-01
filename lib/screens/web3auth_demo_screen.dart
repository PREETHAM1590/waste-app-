import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web3auth_flutter/web3auth_flutter.dart';
import 'package:web3auth_flutter/enums.dart';
import 'package:web3auth_flutter/input.dart';
import 'package:waste_classifier_flutter/wallet/services/wallet_service.dart'; // Import WalletService

class Web3AuthDemoScreen extends StatefulWidget {
  const Web3AuthDemoScreen({super.key});

  @override
  State<Web3AuthDemoScreen> createState() => _Web3AuthDemoScreenState();
}

class _Web3AuthDemoScreenState extends State<Web3AuthDemoScreen> {
  final WalletService _walletService = WalletService.instance; // Use WalletService
  String _status = 'Ready to test';
  String _logs = '';
  bool _isLoading = false;
  String? _walletAddress;

  @override
  void initState() {
    super.initState();
    _walletService.addListener(_onWalletServiceChange);
    _updateWalletAddress();
  }

  @override
  void dispose() {
    _walletService.removeListener(_onWalletServiceChange);
    super.dispose();
  }

  void _onWalletServiceChange() {
    _updateWalletAddress();
  }

  void _updateWalletAddress() {
    setState(() {
      _walletAddress = _walletService.state.walletAddress;
    });
  }

  void _addLog(String message) {
    setState(() {
      _logs += '${DateTime.now().toString().substring(11, 19)}: $message\n';
    });
    debugPrint('[Web3Auth Demo] $message');
  }

  Future<void> _testWeb3AuthConfiguration() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing configuration...';
      _logs = '';
    });

    _addLog('=== Web3Auth Configuration Test ===');
    _addLog('Client ID: ${_walletService.state.userInfo?['clientId']}'); // Assuming clientId is in userInfo
    _addLog('Redirect URI: ${_walletService.state.userInfo?['redirectUri']}'); // Assuming redirectUri is in userInfo

    try {
      // Test 1: Check if Web3Auth is already initialized
      _addLog('Test 1: Checking existing initialization...');
      try {
        await Web3AuthFlutter.getPrivKey();
        _addLog('✅ Web3Auth is already initialized');
      } catch (e) {
        _addLog('⚠️ Web3Auth not initialized or no session: $e');
      }

      // Test 2: Try to get user info
      _addLog('Test 2: Checking existing user session...');
      try {
        final userInfo = await Web3AuthFlutter.getUserInfo();
        _addLog('✅ Found user session: ${userInfo.name}');
        _addLog('User email: ${userInfo.email}');
      } catch (e) {
        _addLog('⚠️ No existing user session: $e');
      }

      setState(() {
        _status = 'Configuration check complete';
      });

    } catch (e) {
      _addLog('❌ Configuration test failed: $e');
      setState(() {
        _status = 'Configuration test failed';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testGoogleLogin() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing Google login...';
    });

    try {
      _addLog('=== Google Login Test ===');
      _addLog('Attempting Google login...');
      
      final success = await _walletService.loginWithGoogle();

      if (success) {
        _addLog('✅ Google login successful!');
        _addLog('User name: ${_walletService.state.userInfo?['name']}');
        _addLog('User email: ${_walletService.state.userInfo?['email']}');
        _addLog('Wallet Address: ${_walletService.state.walletAddress}');
        setState(() {
          _status = 'Google login successful!';
        });
      } else {
        _addLog('❌ Google login failed: ${_walletService.state.error}');
        setState(() {
          _status = 'Google login failed';
        });
      }

    } catch (e) {
      _addLog('❌ Google login failed: $e');
      setState(() {
        _status = 'Google login failed';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testLogout() async {
    setState(() {
      _isLoading = true;
      _status = 'Logging out...';
    });

    try {
      _addLog('=== Logout Test ===');
      await _walletService.logout();
      _addLog('✅ Logout successful');
      
      setState(() {
        _status = 'Logged out successfully';
      });
    } catch (e) {
      _addLog('❌ Logout failed: $e');
      setState(() {
        _status = 'Logout failed';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Web3Auth Demo'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status: $_status',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Wallet Address: ${_walletAddress ?? 'Not connected'}'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),

            // Test buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testWeb3AuthConfiguration,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Test Config'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testGoogleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Test Google Login'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testLogout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Logout'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Logs
            Expanded(
              child: Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      color: Colors.grey[200],
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Debug Logs',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: _logs));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Logs copied to clipboard')),
                              );
                            },
                            icon: const Icon(Icons.copy),
                            tooltip: 'Copy logs',
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          _logs.isEmpty ? 'No logs yet. Tap "Test Config" to start.' : _logs,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (_isLoading)
              const LinearProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

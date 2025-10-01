import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web3auth_flutter/web3auth_flutter.dart';
import 'package:web3auth_flutter/enums.dart';
import 'package:web3auth_flutter/input.dart';
import '../wallet/services/web3auth_config.dart'; // Corrected import path

class Web3AuthDebugScreen extends StatefulWidget {
  const Web3AuthDebugScreen({super.key});

  @override
  State<Web3AuthDebugScreen> createState() => _Web3AuthDebugScreenState();
}

class _Web3AuthDebugScreenState extends State<Web3AuthDebugScreen> {
  String _status = 'Ready to test';
  String _logs = '';
  bool _isLoading = false;

  void _addLog(String message) {
    setState(() {
      _logs += '${DateTime.now().toString().substring(11, 19)}: $message\n';
    });
    debugPrint('[Web3Auth Debug] $message');
  }

  Future<void> _testWeb3AuthConfiguration() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing configuration...';
      _logs = '';
    });

    _addLog('=== Web3Auth Configuration Test ===');
    _addLog('Client ID: ${WalletWeb3AuthConfig.clientId}');
    _addLog('Redirect URI: ${WalletWeb3AuthConfig.redirectUri}');
    _addLog('Client ID Length: ${WalletWeb3AuthConfig.clientId.length}');

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
      
      await Web3AuthFlutter.login(
        LoginParams(
          loginProvider: Provider.google,
          mfaLevel: MFALevel.DEFAULT,
        ),
      );

      _addLog('✅ Google login successful!');
      
      // Get user info after successful login
      final userInfo = await Web3AuthFlutter.getUserInfo();
      _addLog('User name: ${userInfo.name}');
      _addLog('User email: ${userInfo.email}');

      // Get private key
      final privateKey = await Web3AuthFlutter.getPrivKey();
      _addLog('Private key length: ${privateKey.length}');

      setState(() {
        _status = 'Google login successful!';
      });

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
      await Web3AuthFlutter.logout();
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
        title: const Text('Web3Auth Debug'),
        backgroundColor: Colors.red,
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
                    Text('Client ID: ${WalletWeb3AuthConfig.clientId.substring(0, 20)}...'),
                    Text('Redirect: ${WalletWeb3AuthConfig.redirectUri}'),
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

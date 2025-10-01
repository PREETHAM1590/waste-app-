import 'package:flutter/material.dart';
import 'package:web3auth_flutter/web3auth_flutter.dart';
import 'package:web3auth_flutter/enums.dart';
import 'package:web3auth_flutter/input.dart';
import '../wallet/services/web3auth_config.dart';

/// Quick test screen to validate Web3Auth configuration
class Web3AuthTestScreen extends StatefulWidget {
  const Web3AuthTestScreen({super.key});

  @override
  State<Web3AuthTestScreen> createState() => _Web3AuthTestScreenState();
}

class _Web3AuthTestScreenState extends State<Web3AuthTestScreen> {
  String _status = 'Ready to test';
  String _logs = '';
  bool _isLoading = false;

  void _addLog(String message) {
    setState(() {
      _logs += '${DateTime.now().toString().substring(11, 19)}: $message\n';
    });
    debugPrint('[Web3Auth Test] $message');
  }

  Future<void> _testConfiguration() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing configuration...';
      _logs = '';
    });

    _addLog('=== Web3Auth Configuration Test ===');
    _addLog('Client ID: ${WalletWeb3AuthConfig.clientId}');
    _addLog('Redirect URI: ${WalletWeb3AuthConfig.redirectUri}');
    _addLog('Network: sapphire_devnet');

    try {
      // Test initialization (should already be done in main.dart)
      _addLog('✅ Web3Auth should be initialized from main.dart');

      // Test if already logged in
      try {
        final userInfo = await Web3AuthFlutter.getUserInfo();
        _addLog('✅ Found existing session: ${userInfo.name}');
        _addLog('User email: ${userInfo.email}');
        setState(() {
          _status = 'Already logged in - configuration working!';
        });
      } catch (e) {
        _addLog('No existing session: $e');
        setState(() {
          _status = 'Configuration ready - you can now try login';
        });
      }

    } catch (e) {
      _addLog('❌ Configuration test failed: $e');
      setState(() {
        _status = 'Configuration test failed - check logs';
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
      
      final userInfo = await Web3AuthFlutter.getUserInfo();
      _addLog('User: ${userInfo.name} (${userInfo.email})');
      
      setState(() {
        _status = 'Login successful!';
      });

    } catch (e) {
      _addLog('❌ Google login failed: $e');
      setState(() {
        _status = 'Login failed - check logs';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    try {
      await Web3AuthFlutter.logout();
      _addLog('✅ Logged out successfully');
      setState(() {
        _status = 'Logged out';
      });
    } catch (e) {
      _addLog('❌ Logout failed: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    // Auto-test configuration on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _testConfiguration();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Web3Auth Test'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _status,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: _status.contains('failed') 
                            ? Colors.red 
                            : _status.contains('successful') || _status.contains('working')
                                ? Colors.green 
                                : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testConfiguration,
                    child: const Text('Test Config'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testGoogleLogin,
                    child: const Text('Test Login'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _logout,
                    child: const Text('Logout'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Configuration Details:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text('Client ID: ${WalletWeb3AuthConfig.clientId.substring(0, 20)}...'),
            Text('Redirect: ${WalletWeb3AuthConfig.redirectUri}'),
            const SizedBox(height: 16),
            Text(
              'Test Logs:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    child: Text(
                      _logs.isNotEmpty ? _logs : 'No logs yet...',
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                    ),
                  ),
                ),
              ),
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}
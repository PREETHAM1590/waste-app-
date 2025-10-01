import 'package:flutter/material.dart';
import 'package:waste_classifier_flutter/services/web3auth_solana_service.dart';

class SolanaTestScreen extends StatefulWidget {
  const SolanaTestScreen({super.key});

  @override
  State<SolanaTestScreen> createState() => _SolanaTestScreenState();
}

class _SolanaTestScreenState extends State<SolanaTestScreen> {
  final Web3AuthSolanaService _service = Web3AuthSolanaService(SolanaNetwork.devnet);
  String? _address;
  double? _balance;
  bool _loading = false;
  String _status = 'Not connected';

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _status = 'Connecting...';
    });

    try {
      final result = await _service.loginWithGoogle();
      setState(() {
        _address = result.address;
        _status = 'Connected successfully!';
      });
      
      // Load balance
      final balance = await _service.getBalanceSol(result.address);
      setState(() {
        _balance = balance;
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _requestAirdrop() async {
    if (_address == null) return;
    
    setState(() {
      _loading = true;
      _status = 'Requesting airdrop...';
    });

    try {
      final signature = await _service.requestAirdrop(_address!);
      setState(() {
        _status = 'Airdrop requested: ${signature.substring(0, 16)}...';
      });
      
      // Wait and refresh balance
      await Future.delayed(const Duration(seconds: 5));
      final balance = await _service.getBalanceSol(_address!);
      setState(() {
        _balance = balance;
        _status = 'Balance updated!';
      });
    } catch (e) {
      setState(() {
        _status = 'Airdrop error: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solana Web3Auth Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('Status: $_status'),
                    if (_loading) 
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: LinearProgressIndicator(),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_address != null) ...[ 
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Wallet Address:', 
                        style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(_address!, style: const TextStyle(fontFamily: 'monospace')),
                      if (_balance != null) ...[
                        const SizedBox(height: 8),
                        Text('Balance: ${_balance!.toStringAsFixed(6)} SOL',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            ElevatedButton(
              onPressed: _loading ? null : _login,
              child: const Text('Login with Google'),
            ),
            const SizedBox(height: 8),
            if (_address != null)
              ElevatedButton(
                onPressed: _loading ? null : _requestAirdrop,
                child: const Text('Request 1 SOL Airdrop'),
              ),
          ],
        ),
      ),
    );
  }
}

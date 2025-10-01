import 'package:flutter/foundation.dart';
import 'package:flutter/foundation.dart';
import 'package:web3auth_flutter/web3auth_flutter.dart';
import 'package:web3auth_flutter/enums.dart' show Provider;
import 'package:web3auth_flutter/input.dart';
import 'package:solana/solana.dart';

enum SolanaNetwork {
  mainnet,
  devnet,
  testnet,
}

/// Lightweight wrapper around Web3Auth for Solana
class Web3AuthSolanaService {
  final SolanaNetwork _network;
  final String _rpcUrl;

  Web3AuthSolanaService(this._network) : _rpcUrl = _getRpcUrl(_network);

  static String _getRpcUrl(SolanaNetwork network) {
    switch (network) {
      case SolanaNetwork.mainnet:
        return 'https://api.mainnet-beta.solana.com';
      case SolanaNetwork.devnet:
        return 'https://api.devnet.solana.com';
      case SolanaNetwork.testnet:
        return 'https://api.testnet.solana.com';
    }
  }

  Future<Map<String, dynamic>?> getUser() async {
    try {
      final info = await Web3AuthFlutter.getUserInfo();
      return info.toJson();
    } catch (_) {
      return null;
    }
  }

  /// Check if Web3Auth is initialized and ready
  Future<bool> isInitialized() async {
    try {
      await Web3AuthFlutter.getPrivKey();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Check if user is already logged in
  Future<bool> isLoggedIn() async {
    try {
      final userInfo = await Web3AuthFlutter.getUserInfo();
      return userInfo.name?.isNotEmpty ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> logout() async {
    await Web3AuthFlutter.logout();
  }

  /// Login via a provider (e.g., google) and persist private key securely
  Future<({String address, String privKeyHex})> loginWithGoogle() async {
    try {
      debugPrint('Attempting Web3Auth login with Google...');
      
      await Web3AuthFlutter.login(
        LoginParams(loginProvider: Provider.google),
      );
      debugPrint('Web3Auth login successful');

      // Get ED25519 private key for Solana
      final privKeyHex = await Web3AuthFlutter.getEd25519PrivKey();
      if (privKeyHex.isEmpty) {
        throw Exception('Web3Auth did not return an ed25519 private key');
      }
      debugPrint('Private key obtained successfully');
      
      final address = await _addressFromPrivKeyHex(privKeyHex);
      debugPrint('Wallet address generated: $address');
      
      return (address: address, privKeyHex: privKeyHex);
    } catch (e) {
      debugPrint('Web3Auth login error: $e');
      if (e.toString().contains('User cancelled')) {
        throw Exception('Login was cancelled by user');
      } else if (e.toString().contains('network') || e.toString().contains('internet')) {
        throw Exception('Network error. Please check your internet connection.');
      } else if (e.toString().contains('client_id') || e.toString().contains('clientId')) {
        throw Exception('Invalid Web3Auth configuration. Please contact support.');
      } else {
        throw Exception('Login failed: ${e.toString()}');
      }
    }
  }

  Future<double> getBalanceSol(String address) async {
    final rpc = RpcClient(_rpcUrl);
    final result = await rpc.getBalance(address);
    return result.value / lamportsPerSol;
  }

  Future<String> requestAirdrop(String address, {double solAmount = 1}) async {
    final rpc = RpcClient(_rpcUrl);
    final sig = await rpc.requestAirdrop(address, (solAmount * lamportsPerSol).toInt());
    return sig;
  }

  Future<String> sendSol({
    required String to,
    required double amountSol,
  }) async {
    String? priv = await Web3AuthFlutter.getEd25519PrivKey();
    
    if (priv == null) throw Exception('No wallet found. Please create or connect a wallet first.');

    final kp = await _keypairFromPrivKeyHex(priv);
    final client = RpcClient(_rpcUrl);
    
    final message = Message.only(
      SystemInstruction.transfer(
        fundingAccount: kp.publicKey,
        recipientAccount: Ed25519HDPublicKey.fromBase58(to),
        lamports: (amountSol * lamportsPerSol).toInt(),
      ),
    );

    final sig = await client.signAndSendTransaction(
      message,
      [kp],
      commitment: Commitment.confirmed,
    );
    return sig;
  }

  /// Get recent transactions (signatures) for the address
  Future<List<String>> getRecentTransactionSignatures(String address, {int limit = 10}) async {
    final rpc = RpcClient(_rpcUrl);
    final list = await rpc.getSignaturesForAddress(address, limit: limit);
    return list.map((e) => e.signature).toList();
  }

  // Helpers
  Future<String> _addressFromPrivKeyHex(String privHex) async {
    final kp = await _keypairFromPrivKeyHex(privHex);
    return kp.publicKey.toBase58();
  }

  Future<Ed25519HDKeyPair> _keypairFromPrivKeyHex(String privHex) async {
    final bytes = _hexToBytes(privHex);
    return Ed25519HDKeyPair.fromPrivateKeyBytes(privateKey: bytes);
  }

  Uint8List _hexToBytes(String hex) {
    final cleaned = hex.startsWith('0x') ? hex.substring(2) : hex;
    final result = Uint8List(cleaned.length ~/ 2);
    for (int i = 0; i < cleaned.length; i += 2) {
      result[i ~/ 2] = int.parse(cleaned.substring(i, i + 2), radix: 16);
    }
    return result;
  }
}

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:web3auth_flutter/web3auth_flutter.dart';
import 'package:web3auth_flutter/enums.dart';
import 'package:web3auth_flutter/input.dart';
import 'package:solana/solana.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ed25519_edwards/ed25519_edwards.dart' as ed25519;
import 'web3auth_config.dart';
import '../models/wallet_state.dart';
import 'package:waste_classifier_flutter/core/service_locator.dart'; // Import ServiceLocator

/// Main wallet service for handling Web3Auth and Solana operations
class WalletService extends ChangeNotifier {
  static final WalletService _instance = WalletService._internal();
  static WalletService get instance => _instance;
  WalletService._internal();

  // Services
  SolanaClient? _solanaClient;
  Ed25519HDKeyPair? _keyPair;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // State
  WalletState _state = const WalletState();
  WalletState get state => _state;
  
  // Initialization state
  bool _isInitialized = false;
  bool _isInitializing = false;
  
  // Balance polling
  Timer? _balanceTimer;
  static const Duration _balanceRefreshInterval = Duration(seconds: 10);

  // Constants
  static const String _balanceKey = 'wallet_balance';
  static const String _addressKey = 'wallet_address';
  static const String _privKeyKey = 'w3a_solana_privkey';
  static const lamportsPerSol = 1000000000;

  /// Initialize Web3Auth and wallet services
  Future<bool> initialize() async {
    // Prevent multiple simultaneous initializations
    if (_isInitialized) {
      if (kDebugMode) {
        debugPrint('WalletService already initialized');
      }
      return _state.isLoggedIn;
    }
    
    if (_isInitializing) {
      if (kDebugMode) {
        debugPrint('WalletService initialization already in progress');
      }
      return false;
    }
    
    _isInitializing = true;
    
    try {
      if (kDebugMode) {
        debugPrint('🔐 Initializing Web3Auth...');
      }

      // Initialize Web3Auth with proper error handling
      try {
        await Web3AuthFlutter.init(Web3AuthOptions(
          clientId: WalletWeb3AuthConfig.clientId,
          network: WalletWeb3AuthConfig.web3AuthNetwork,
          redirectUrl: Uri.parse(WalletWeb3AuthConfig.redirectUri),
          whiteLabel: WhiteLabelData(
            appName: WalletWeb3AuthConfig.appName,
            mode: ThemeModes.dark,
          ),
          sessionTime: WalletWeb3AuthConfig.sessionTime,
        ));

        await Web3AuthFlutter.initialize();
      } catch (e) {
        if (kDebugMode) {
          debugPrint('❌ Web3Auth initialization failed: $e');
        }
        // Don't fail the entire service if Web3Auth fails
        // The app can still work with local wallet functionality
        _updateState(_state.copyWith(
          isInitialized: true,
          error: 'Web3Auth unavailable. Some features may be limited.',
        ));
      }

      // Initialize Solana client from ServiceLocator (with fallback)
      try {
        if (ServiceLocator.isRegistered<SolanaClient>()) {
          _solanaClient = ServiceLocator.getIt<SolanaClient>();
        } else {
          if (kDebugMode) {
            debugPrint('⚠️ SolanaClient not found in ServiceLocator, some features may be limited');
          }
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('⚠️ Failed to get SolanaClient from ServiceLocator: $e');
        }
      }

      // Check if already logged in (only if Web3Auth is available)
      bool isLoggedIn = false;
      try {
        isLoggedIn = await checkLoginStatus();
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Login status check failed: $e');
        }
      }
      
      _isInitialized = true;
      
      if (kDebugMode) {
        debugPrint('✅ Wallet service initialized. Logged in: $isLoggedIn');
      }

      return isLoggedIn;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Wallet service initialization failed: $e');
      }
      _updateState(_state.copyWith(
        isInitialized: true,
        error: 'Service initialization failed: ${e.toString()}',
      ));
      return false;
    } finally {
      _isInitializing = false;
    }
  }

  /// Check if user is currently logged in
  Future<bool> checkLoginStatus() async {
    try {
      final privateKey = await Web3AuthFlutter.getEd25519PrivKey();
      final userInfo = await Web3AuthFlutter.getUserInfo();
      
      if (privateKey.isNotEmpty && (userInfo.email?.isNotEmpty ?? false)) {
        await _initializeWallet(privateKey, _convertUserInfo(userInfo));
        return true;
      }
      
      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Login status check failed: $e');
      }
      return false;
    }
  }

  /// Login with Google
  Future<bool> loginWithGoogle() async {
    return await _login(Provider.google);
  }

  /// Login with email
  Future<bool> loginWithEmail(String email) async {
    return await _login(
      Provider.email_passwordless,
      extraOptions: ExtraLoginOptions(login_hint: email),
    );
  }

  /// Login with Twitter/X
  Future<bool> loginWithTwitter() async {
    return await _login(Provider.twitter);
  }

  /// Login with Facebook
  Future<bool> loginWithFacebook() async {
    return await _login(Provider.facebook);
  }

  /// Generic login method
  Future<bool> _login(Provider provider, {ExtraLoginOptions? extraOptions}) async {
    try {
      _updateState(_state.copyWith(isLoading: true, error: null));

      await Web3AuthFlutter.login(LoginParams(
        loginProvider: provider,
        extraLoginOptions: extraOptions,
      ));

      final privateKey = await Web3AuthFlutter.getEd25519PrivKey();
      final userInfo = await Web3AuthFlutter.getUserInfo();

      if (privateKey.isNotEmpty && (userInfo.email?.isNotEmpty ?? false)) {
        await _initializeWallet(privateKey, _convertUserInfo(userInfo));
        return true;
      } else {
        throw Exception('Failed to get wallet credentials');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Login failed: $e');
      }
      _updateState(_state.copyWith(
        isLoading: false,
        error: 'Login failed: ${e.toString()}',
      ));
      return false;
    }
  }

  /// Fallback method to create a local wallet when Web3Auth is not available
  Future<({String address, String privKeyHex})> createLocalWallet() async {
    try {
      // Generate a new Ed25519 key pair for Solana using ed25519_edwards
      final edkp = ed25519.generateKey();
      final privateKeyBytes = List<int>.from(edkp.privateKey.bytes);
      final privKeyHex = privateKeyBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
      // Derive address using our existing helper to reconstruct a Solana keypair
      final address = await _addressFromPrivKeyHex(privKeyHex);
      
      // Store the private key securely
      await _secureStorage.write(key: '${_privKeyKey}_local', value: privKeyHex);
      
      debugPrint('Local wallet created with address: $address');
      return (address: address, privKeyHex: privKeyHex);
    } catch (e) {
      throw Exception('Failed to create local wallet: $e');
    }
  }

  /// Get stored local wallet private key
  Future<String?> getStoredLocalPrivKey() async => _secureStorage.read(key: '${_privKeyKey}_local');

  /// Get local wallet address
  Future<String?> getLocalAddress() async {
    final priv = await getStoredLocalPrivKey();
    if (priv == null) return null;
    return _addressFromPrivKeyHex(priv);
  }

  /// Check if local wallet exists
  Future<bool> hasLocalWallet() async {
    final priv = await getStoredLocalPrivKey();
    return priv != null;
  }

  /// Initialize wallet with private key and user info
  Future<void> _initializeWallet(String privateKey, Map<String, dynamic> userInfo) async {
    try {
      // Convert hex private key to bytes and create keypair
      final privateKeyBytes = Uint8List.fromList(_hexToBytes(privateKey));
      _keyPair = await Ed25519HDKeyPair.fromPrivateKeyBytes(
        privateKey: privateKeyBytes.sublist(0, 32),
      );

      final address = _keyPair!.address;
      
      // Save wallet info securely
      await _secureStorage.write(key: _addressKey, value: address);
      
      // Fetch balance, transactions, and token balances
      final balance = await _fetchBalance(address);
      final transactions = await _fetchTransactions(address);
      final tokenBalances = await _fetchTokenBalances(address);
      
      // Update state
      _updateState(_state.copyWith(
        isLoggedIn: true,
        isLoading: false,
        userInfo: userInfo,
        walletAddress: address,
        balance: balance,
        transactions: transactions,
        tokenBalances: tokenBalances,
        error: null,
      ));

      if (kDebugMode) {
        debugPrint('✅ Wallet initialized: $address');
        debugPrint('💰 Balance: $balance SOL');
      }
      
      // Start automatic balance polling
      _startBalancePolling();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Wallet initialization failed: $e');
      }
      _updateState(_state.copyWith(
        isLoading: false,
        error: 'Wallet initialization failed: ${e.toString()}',
      ));
    }
  }

  /// Fetch wallet balance
  Future<double> _fetchBalance(String address) async {
    try {
      if (_solanaClient == null) return 0.0;
      
      final response = await _solanaClient!.rpcClient.getBalance(address);
      final balance = response.value / lamportsPerSol; // Convert lamports to SOL
      
      // Cache balance
      await _secureStorage.write(key: _balanceKey, value: balance.toString());
      
      return balance;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching balance: $e');
      }
      // Try to get cached balance
      final cachedBalance = await _secureStorage.read(key: _balanceKey);
      return double.tryParse(cachedBalance ?? '0') ?? 0.0;
    }
  }

  /// Start automatic balance polling
  void _startBalancePolling() {
    _stopBalancePolling(); // Stop any existing timer
    
    _balanceTimer = Timer.periodic(_balanceRefreshInterval, (timer) {
      if (_state.walletAddress != null && _state.isLoggedIn) {
        refreshBalance();
      } else {
        _stopBalancePolling();
      }
    });
  }
  
  /// Stop automatic balance polling
  void _stopBalancePolling() {
    _balanceTimer?.cancel();
    _balanceTimer = null;
  }
  
  /// Refresh wallet balance
  Future<void> refreshBalance() async {
    if (_state.walletAddress == null) return;
    
    try {
      _updateState(_state.copyWith(isLoadingBalance: true));
      
      final balance = await _fetchBalance(_state.walletAddress!);
      final transactions = await _fetchTransactions(_state.walletAddress!);
      
      // Fetch token balances separately to avoid blocking main balance update
      Map<String, double> tokenBalances = {};
      try {
        tokenBalances = await _fetchTokenBalances(_state.walletAddress!);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('⚠️ Token balance fetch failed (non-critical): $e');
        }
      }
      
      _updateState(_state.copyWith(
        balance: balance,
        transactions: transactions,
        tokenBalances: tokenBalances,
        isLoadingBalance: false,
      ));
      
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Balance refresh failed: $e');
      }
      _updateState(_state.copyWith(
        isLoadingBalance: false,
        error: 'Failed to refresh balance: ${e.toString()}',
      ));
    }
  }

  /// Request airdrop for testing (Devnet only)
  Future<bool> requestAirdrop() async {
    if (_keyPair == null || _solanaClient == null) return false;
    
    try {
      _updateState(_state.copyWith(isLoading: true));
      
      await _solanaClient!.requestAirdrop(
        address: _keyPair!.publicKey,
        lamports: lamportsPerSol, // 1 SOL
      );
      
      // Wait a moment for airdrop to process
      await Future.delayed(const Duration(seconds: 3));
      
      // Refresh balance and transactions
      await refreshBalance();
      
      _updateState(_state.copyWith(isLoading: false));
      
      if (kDebugMode) {
        debugPrint('✅ Airdrop requested successfully');
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Airdrop failed: $e');
      }
      _updateState(_state.copyWith(
        isLoading: false,
        error: 'Airdrop failed: ${e.toString()}',
      ));
      return false;
    }
  }

  /// Send SOL to another address
  Future<String?> sendSol(String toAddress, double amount) async {
    if (_keyPair == null || _solanaClient == null) return null;
    
    try {
      _updateState(_state.copyWith(isLoading: true));
      
      final lamports = (amount * lamportsPerSol).toInt();
      
      final txHash = await _solanaClient!.transferLamports(
        source: _keyPair!,
        destination: Ed25519HDPublicKey.fromBase58(toAddress),
        lamports: lamports,
      );
      
      // Refresh balance and transactions after successful transaction
      await Future.delayed(const Duration(seconds: 2));
      await refreshBalance();
      
      _updateState(_state.copyWith(isLoading: false));
      
      if (kDebugMode) {
        debugPrint('✅ Transaction sent: $txHash');
      }
      
      return txHash;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Transaction failed: $e');
      }
      _updateState(_state.copyWith(
        isLoading: false,
        error: 'Transaction failed: ${e.toString()}',
      ));
      return null;
    }
  }

  /// Fetch SPL token balances
  Future<Map<String, double>> _fetchTokenBalances(String address) async {
    try {
      if (_solanaClient == null) return {};

      final Map<String, double> balances = {};
      
      // TODO: Token balance fetching temporarily disabled due to RPC client API compatibility
      // The main SOL balance still works perfectly
      // Will be re-enabled when Solana package is updated
      return {};
      
      /* Original code - disabled for now
      try {
        final response = await _solanaClient!.rpcClient.call(
          'getTokenAccountsByOwner',
          [
            address,
            {'programId': 'TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA'},
            {'encoding': 'jsonParsed'},
          ],
        );

        if (response is Map && response['value'] is List) {
          final accounts = response['value'] as List;

          for (final account in accounts) {
            try {
              if (account is Map && account['account'] is Map) {
                final accountData = account['account'] as Map;
                if (accountData['data'] is Map) {
                  final data = accountData['data'] as Map;
                  if (data['parsed'] is Map) {
                    final parsed = data['parsed'] as Map;
                    if (parsed['info'] is Map) {
                      final info = parsed['info'] as Map;
                      final mint = info['mint'];
                      final tokenAmount = info['tokenAmount'];
                      
                      if (mint != null && tokenAmount is Map) {
                        final uiAmount = tokenAmount['uiAmount'];
                        if (uiAmount != null) {
                          final amount = uiAmount is num ? uiAmount.toDouble() : 0.0;
                          if (amount > 0) {
                            balances[mint.toString()] = amount;
                          }
                        }
                      }
                    }
                  }
                }
              }
            } catch (e) {
              // Skip invalid token accounts
              continue;
            }
          }
        }
      } catch (rpcError) {
        // RPC error, return empty balances
      }

      return balances;
      */
    } catch (e) {
      return {};
    }
  }

  /// Fetch transaction history for a given address
  Future<List<String>> _fetchTransactions(String address) async {
    try {
      if (_solanaClient == null) return [];

      final signatures = await _solanaClient!.rpcClient.getSignaturesForAddress(
        address,
        limit: 10, // Fetch last 10 transactions
      );

      return signatures.map((sig) => sig.signature).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching transactions: $e');
      }
      return [];
    }
  }

  /// Logout from Web3Auth
  Future<void> logout() async {
    try {
      // Stop balance polling
      _stopBalancePolling();
      
      await Web3AuthFlutter.logout();
      await _secureStorage.deleteAll();
      
      _updateState(const WalletState());
      
      if (kDebugMode) {
        debugPrint('✅ Logged out successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Logout failed: $e');
      }
      _updateState(_state.copyWith(
        error: 'Logout failed: ${e.toString()}',
      ));
    }
  }

  /// Clear any errors
  void clearError() {
    _updateState(_state.copyWith(error: null));
  }

  /// Convert TorusUserInfo to Map<String, dynamic>
  Map<String, dynamic> _convertUserInfo(userInfo) {
    return {
      'name': userInfo.name ?? '',
      'email': userInfo.email ?? '',
      'profileImage': userInfo.profileImage ?? '',
      'verifier': userInfo.verifier ?? '',
      'verifierId': userInfo.verifierId ?? '',
      'typeOfLogin': userInfo.typeOfLogin ?? '',
      'aggregateVerifier': userInfo.aggregateVerifier ?? '',
      'dappShare': userInfo.dappShare ?? '',
      'idToken': userInfo.idToken ?? '',
      'oAuthIdToken': userInfo.oAuthIdToken ?? '',
      'oAuthAccessToken': userInfo.oAuthAccessToken ?? '',
      'isMfaEnabled': userInfo.isMfaEnabled ?? false,
    };
  }

  /// Helper method to convert hex string to bytes
  List<int> _hexToBytes(String hex) {
    // Remove '0x' prefix if present
    if (hex.startsWith('0x')) {
      hex = hex.substring(2);
    }
    
    final bytes = <int>[];
    for (int i = 0; i < hex.length; i += 2) {
      final byte = hex.substring(i, i + 2);
      bytes.add(int.parse(byte, radix: 16));
    }
    return bytes;
  }

  /// Helper method to convert bytes to hex string
  String _bytesToHex(List<int> bytes) {
    return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  }

  /// Helper to derive address from private key hex
  Future<String> _addressFromPrivKeyHex(String privHex) async {
    final kp = await _keypairFromPrivKeyHex(privHex);
    return kp.publicKey.toBase58();
  }

  /// Helper to create keypair from private key hex
  Future<Ed25519HDKeyPair> _keypairFromPrivKeyHex(String privHex) async {
    final bytes = _hexToBytes(privHex);
    return Ed25519HDKeyPair.fromPrivateKeyBytes(privateKey: bytes);
  }

  /// Update state and notify listeners
  void _updateState(WalletState newState) {
    _state = newState;
    notifyListeners();
  }
}

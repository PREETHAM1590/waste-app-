import 'package:shared_preferences/shared_preferences.dart';

enum SolanaNetwork {
  mainnetBeta('Mainnet Beta', 'https://api.mainnet-beta.solana.com'),
  testnet('Testnet', 'https://api.testnet.solana.com'),
  devnet('Devnet', 'https://api.devnet.solana.com');

  const SolanaNetwork(this.displayName, this.rpcUrl);
  
  final String displayName;
  final String rpcUrl;
}

class SolanaNetworkConfig {
  static const String _networkKey = 'selected_solana_network';
  static SolanaNetwork _currentNetwork = SolanaNetwork.devnet; // Default to devnet
  
  /// Get the currently selected network
  static SolanaNetwork get currentNetwork => _currentNetwork;
  
  /// Get the RPC URL for the current network
  static String get rpcUrl => _currentNetwork.rpcUrl;
  
  /// Initialize and load saved network preference
  static Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedNetwork = prefs.getString(_networkKey);
      
      if (savedNetwork != null) {
        _currentNetwork = SolanaNetwork.values.firstWhere(
          (network) => network.name == savedNetwork,
          orElse: () => SolanaNetwork.devnet,
        );
      }
    } catch (e) {
      print('Error loading network config: $e');
    }
  }
  
  /// Set the active network and save preference
  static Future<void> setNetwork(SolanaNetwork network) async {
    try {
      _currentNetwork = network;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_networkKey, network.name);
    } catch (e) {
      print('Error saving network config: $e');
    }
  }
  
  /// Get all available networks
  static List<SolanaNetwork> get allNetworks => SolanaNetwork.values;
}

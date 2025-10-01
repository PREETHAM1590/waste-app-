/// Network configuration for Solana and Web3Auth
class NetworkConfig {
  // Current active network
  static const SolanaNetwork currentNetwork = SolanaNetwork.mainnet;
  
  // Web3Auth uses sapphire_devnet for your client ID
  // Don't change this unless you create a new Web3Auth project
  static const String web3AuthNetwork = 'sapphire_devnet';
}

enum SolanaNetwork {
  mainnet,
  devnet,
  testnet,
}

class SolanaNetworkConfig {
  static const Map<SolanaNetwork, NetworkInfo> networks = {
    SolanaNetwork.mainnet: NetworkInfo(
      name: 'Mainnet Beta',
      rpcUrl: 'https://api.mainnet-beta.solana.com',
      wsUrl: 'wss://api.mainnet-beta.solana.com',
      explorerUrl: 'https://explorer.solana.com',
      chainId: '0x1',
      isTestnet: false,
    ),
    SolanaNetwork.devnet: NetworkInfo(
      name: 'Devnet',
      rpcUrl: 'https://api.devnet.solana.com',
      wsUrl: 'wss://api.devnet.solana.com',
      explorerUrl: 'https://explorer.solana.com?cluster=devnet',
      chainId: '0x2',
      isTestnet: true,
    ),
    SolanaNetwork.testnet: NetworkInfo(
      name: 'Testnet',
      rpcUrl: 'https://api.testnet.solana.com',
      wsUrl: 'wss://api.testnet.solana.com',
      explorerUrl: 'https://explorer.solana.com?cluster=testnet',
      chainId: '0x3',
      isTestnet: true,
    ),
  };
  
  static NetworkInfo get current => networks[NetworkConfig.currentNetwork]!;
  
  static String get rpcUrl => current.rpcUrl;
  static String get wsUrl => current.wsUrl;
  static String get explorerUrl => current.explorerUrl;
  static String get name => current.name;
  static bool get isTestnet => current.isTestnet;
}

class NetworkInfo {
  final String name;
  final String rpcUrl;
  final String wsUrl;
  final String explorerUrl;
  final String chainId;
  final bool isTestnet;
  
  const NetworkInfo({
    required this.name,
    required this.rpcUrl,
    required this.wsUrl,
    required this.explorerUrl,
    required this.chainId,
    required this.isTestnet,
  });
}

/// Faucet URLs for test networks
class FaucetConfig {
  static String? getFaucetUrl(SolanaNetwork network) {
    switch (network) {
      case SolanaNetwork.devnet:
        return 'https://faucet.solana.com';
      case SolanaNetwork.testnet:
        return 'https://faucet.solana.com';
      case SolanaNetwork.mainnet:
        return null; // No faucet for mainnet
    }
  }
  
  static bool hasFaucet(SolanaNetwork network) {
    return getFaucetUrl(network) != null;
  }
}

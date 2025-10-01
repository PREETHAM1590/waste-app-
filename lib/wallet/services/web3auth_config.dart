import 'dart:io';
import 'package:web3auth_flutter/enums.dart'; // Import Web3Auth's Network enum

/// Enum for supported Web3Auth networks
enum Web3AuthNetwork {
  mainnet,
  testnet,
  sapphire_mainnet,
  sapphire_devnet,
}

/// Web3Auth configuration for Waste Classifier Wallet
class WalletWeb3AuthConfig {
  // Web3Auth Client ID - From Web3Auth Dashboard (✅ CONFIGURED)
  static const String clientId = "BFg79_oqmd5SJzJYpH9bMvw4s-klY87HSt32G_lOnTFV8lzYuixvz83qhZHkpyZ1R6gfGITXkLYt8u3VCSM2_WI";
  
  /// Configurable network for Web3Auth
  static Web3AuthNetwork currentNetwork = Web3AuthNetwork.sapphire_devnet; // Default to sapphire_devnet
  
  /// Get the Web3Auth Network enum based on currentNetwork
  static Network get web3AuthNetwork {
    switch (currentNetwork) {
      case Web3AuthNetwork.mainnet:
        return Network.mainnet;
      case Web3AuthNetwork.testnet:
        return Network.testnet;
      case Web3AuthNetwork.sapphire_mainnet:
        return Network.sapphire_mainnet;
      case Web3AuthNetwork.sapphire_devnet:
        return Network.sapphire_devnet;
    }
  }
  
  /// Get platform-specific redirect URI (✅ CONFIGURED)
  static String get redirectUri {
    if (Platform.isAndroid) {
      return 'com.wastemanagement.app://auth';
    } else if (Platform.isIOS) {
      return 'com.wastemanagement.app://auth';
    } else {
      return 'http://localhost:8080/auth';
    }
  }
  
  /// App display name in Web3Auth UI
  static const String appName = "Waste Wise Wallet";
  
  /// Theme mode for Web3Auth UI
  static const String themeMode = "dark";
  
  /// Session timeout in seconds (1 day)
  static const int sessionTime = 86400;
}

import 'package:flutter/foundation.dart';

/// Represents the current state of the wallet
@immutable
class WalletState {
  final bool isInitialized;
  final bool isLoggedIn;
  final bool isLoading;
  final bool isLoadingBalance;
  final Map<String, dynamic>? userInfo;
  final String? walletAddress;
  final double balance;
  final List<String> transactions; // Added for transaction history
  final Map<String, double> tokenBalances; // SPL token balances by mint address
  final String? error;

  const WalletState({
    this.isInitialized = false,
    this.isLoggedIn = false,
    this.isLoading = false,
    this.isLoadingBalance = false,
    this.userInfo,
    this.walletAddress,
    this.balance = 0.0,
    this.transactions = const [], // Initialize transactions
    this.tokenBalances = const {}, // Initialize token balances
    this.error,
  });

  /// Get user's display name from userInfo
  String get userName {
    if (userInfo == null) return 'Unknown User';
    return userInfo!['name'] ?? userInfo!['email'] ?? 'User';
  }

  /// Get user's email from userInfo
  String get userEmail {
    if (userInfo == null) return '';
    return userInfo!['email'] ?? '';
  }

  /// Get user's profile image URL from userInfo
  String? get userProfileImage {
    if (userInfo == null) return null;
    return userInfo!['profileImage'];
  }

  /// Get shortened wallet address for display
  String get shortAddress {
    if (walletAddress == null || walletAddress!.length < 12) {
      return walletAddress ?? '';
    }
    return '${walletAddress!.substring(0, 6)}...${walletAddress!.substring(walletAddress!.length - 6)}';
  }

  /// Get formatted balance for display
  String get formattedBalance {
    return balance.toStringAsFixed(4);
  }

  /// Get ECO token balance (placeholder - not yet implemented)
  double get ecoBalance {
    // TODO: Implement ECO token balance tracking
    return 0.0;
  }

  /// Check if wallet is ready for operations
  bool get isWalletReady {
    return isInitialized && isLoggedIn && walletAddress != null;
  }

  /// Create a copy with updated values
  WalletState copyWith({
    bool? isInitialized,
    bool? isLoggedIn,
    bool? isLoading,
    bool? isLoadingBalance,
    Map<String, dynamic>? userInfo,
    String? walletAddress,
    double? balance,
    List<String>? transactions, // Added for transaction history
    Map<String, double>? tokenBalances, // Added for SPL token balances
    String? error,
  }) {
    return WalletState(
      isInitialized: isInitialized ?? this.isInitialized,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isLoading: isLoading ?? this.isLoading,
      isLoadingBalance: isLoadingBalance ?? this.isLoadingBalance,
      userInfo: userInfo ?? this.userInfo,
      walletAddress: walletAddress ?? this.walletAddress,
      balance: balance ?? this.balance,
      transactions: transactions ?? this.transactions, // Update transactions
      tokenBalances: tokenBalances ?? this.tokenBalances, // Update token balances
      error: error ?? this.error,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is WalletState &&
      other.isInitialized == isInitialized &&
      other.isLoggedIn == isLoggedIn &&
      other.isLoading == isLoading &&
      other.isLoadingBalance == isLoadingBalance &&
      mapEquals(other.userInfo, userInfo) &&
      other.walletAddress == walletAddress &&
      other.balance == balance &&
      other.error == error;
  }

  @override
  int get hashCode {
    return Object.hash(
      isInitialized,
      isLoggedIn,
      isLoading,
      isLoadingBalance,
      userInfo,
      walletAddress,
      balance,
      transactions,
      error,
    );
  }

  @override
  String toString() {
    return 'WalletState('
        'isInitialized: $isInitialized, '
        'isLoggedIn: $isLoggedIn, '
        'isLoading: $isLoading, '
        'isLoadingBalance: $isLoadingBalance, '
        'userInfo: $userInfo, '
        'walletAddress: $walletAddress, '
        'balance: $balance, '
        'transactions: $transactions, '
        'error: $error'
        ')';
  }
}
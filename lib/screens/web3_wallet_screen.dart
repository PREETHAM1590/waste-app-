import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:waste_classifier_flutter/wallet/services/wallet_service.dart';
import 'package:waste_classifier_flutter/core/widgets/custom_dialog.dart';
import 'package:waste_classifier_flutter/config/network_config.dart';
import 'package:url_launcher/url_launcher.dart';

class Web3WalletScreen extends StatefulWidget {
  const Web3WalletScreen({super.key});

  @override
  State<Web3WalletScreen> createState() => _Web3WalletScreenState();
}

class _Web3WalletScreenState extends State<Web3WalletScreen> {
  final _walletService = WalletService.instance;
  bool _isLoading = true;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _initializeWallet();
  }

  Future<void> _initializeWallet() async {
    setState(() => _isLoading = true);
    
    final initialized = await _walletService.initialize();
    if (!initialized && mounted) {
      // Not logged in, redirect to login
      context.go('/wallet-connect');
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _refreshBalance() async {
    if (_isRefreshing) return;
    
    setState(() => _isRefreshing = true);
    await _walletService.refreshBalance();
    setState(() => _isRefreshing = false);
  }

  void _copyAddress() {
    if (_walletService.state.walletAddress != null) {
      Clipboard.setData(ClipboardData(text: _walletService.state.walletAddress!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Address copied to clipboard')),
      );
    }
  }

  Future<void> _handleAction(String action) async {
    showLoader(context);
    
    try {
      switch (action) {
        case 'send':
        case 'receive':
        case 'buy':
        case 'swap':
          // Open Web3Auth wallet services
          // Since the Flutter SDK doesn't have a direct wallet UI,
          // we'll open the web wallet in a browser
          final walletUrl = 'https://app.openlogin.com';
          if (await canLaunchUrl(Uri.parse(walletUrl))) {
            await launchUrl(
              Uri.parse(walletUrl),
              mode: LaunchMode.externalApplication,
            );
          } else {
            throw Exception('Could not open Web3Auth wallet');
          }
          break;
      }
    } catch (e) {
      if (mounted) {
        showInfoDialog(context, 'Error: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        removeDialog(context);
      }
    }
  }

  Future<void> _logout() async {
    await _walletService.logout();
    if (mounted) {
      // Navigate back to welcome screen after logout
      context.go('/');  // Go to splash/auth wrapper
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final theme = Theme.of(context);
    final address = _walletService.state.walletAddress ?? '';
    final balance = _walletService.state.balance;
    final userEmail = _walletService.state.userInfo?['email'] ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshBalance,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header with logout button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Wallet',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout),
                        onPressed: _logout,
                        tooltip: 'Logout',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Balance Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Address with copy button
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${address.substring(0, 11)}...${address.substring(address.length - 5)}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontFamily: 'monospace',
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy, size: 20),
                              onPressed: _copyAddress,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              color: Colors.black54,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Balance
                        Text(
                          '${balance.toStringAsFixed(4)} SOL',
                          style: theme.textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 36,
                          ),
                        ),
                        Text(
                          'USD \$${(balance * 30).toStringAsFixed(2)}', // Assuming 1 SOL = $30
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // Network indicator and faucet button
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: SolanaNetworkConfig.isTestnet 
                                  ? Colors.orange.withOpacity(0.2)
                                  : Colors.green.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: SolanaNetworkConfig.isTestnet
                                    ? Colors.orange
                                    : Colors.green,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.circle,
                                    size: 8,
                                    color: SolanaNetworkConfig.isTestnet
                                      ? Colors.orange
                                      : Colors.green,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    SolanaNetworkConfig.name,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: SolanaNetworkConfig.isTestnet
                                        ? Colors.orange
                                        : Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (FaucetConfig.hasFaucet(NetworkConfig.currentNetwork)) ...[
                              const SizedBox(width: 8),
                              TextButton.icon(
                                onPressed: () async {
                                  final faucetUrl = FaucetConfig.getFaucetUrl(
                                    NetworkConfig.currentNetwork,
                                  );
                                  if (faucetUrl != null) {
                                    await launchUrl(Uri.parse(faucetUrl));
                                  }
                                },
                                icon: const Icon(Icons.water_drop, size: 16),
                                label: const Text('Get Test SOL'),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Action buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildActionButton(
                              icon: Icons.send,
                              label: 'Send',
                              onTap: () => _handleAction('send'),
                            ),
                            _buildActionButton(
                              icon: Icons.download,
                              label: 'Receive',
                              onTap: () => _handleAction('receive'),
                            ),
                            _buildActionButton(
                              icon: Icons.shopping_cart,
                              label: 'Buy',
                              onTap: () => _handleAction('buy'),
                            ),
                            _buildActionButton(
                              icon: Icons.swap_horiz,
                              label: 'Swap',
                              onTap: () => _handleAction('swap'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Your Tokens section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Your Tokens',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            'Show All Tokens',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                          Switch(
                            value: true,
                            onChanged: (value) {},
                            activeColor: theme.primaryColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Token list (placeholder)
                  _buildTokenItem('Solana', 'SOL', balance, balance * 30),
                  _buildTokenItem('USDC', 'USDC', 0, 0),
                  
                  const SizedBox(height: 24),

                  // Open Wallet button
                  ElevatedButton(
                    onPressed: () => _handleAction('wallet'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Open Web3Auth Wallet',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // User info if available
                  if (userEmail != null) ...[
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        'Logged in as: $userEmail',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
      
      // Bottom navigation
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Tokens',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.nfc),
            label: 'NFT',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timeline),
            label: 'Activity',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        onTap: (index) {
          // Handle navigation
        },
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTokenItem(String name, String symbol, double amount, double usdValue) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Text(
            symbol.substring(0, 1),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(name),
        subtitle: Text(symbol),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              amount.toStringAsFixed(4),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '\$${usdValue.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

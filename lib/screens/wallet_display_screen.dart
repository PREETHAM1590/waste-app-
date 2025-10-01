import 'package:flutter/material.dart';

class WalletDisplayScreen extends StatefulWidget {
  const WalletDisplayScreen({super.key});

  @override
  State<WalletDisplayScreen> createState() => _WalletDisplayScreenState();
}

class _WalletDisplayScreenState extends State<WalletDisplayScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 350, // Adjust width as needed
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset('assets/images/metamask_logo.png', width: 30, height: 30), // Placeholder for wallet icon
                  const Text(
                    '0x11123...23423', // Placeholder address
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      // Handle close wallet
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                '325.58 USD', // Placeholder balance
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildWalletActionButton('Send', Icons.send),
                  _buildWalletActionButton('Receive', Icons.call_received),
                  _buildWalletActionButton('Buy', Icons.shopping_cart),
                  _buildWalletActionButton('Swap', Icons.swap_horiz),
                ],
              ),
              const SizedBox(height: 20),
              DefaultTabController(
                length: 4,
                child: Column(
                  children: [
                    const TabBar(
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Colors.blue,
                      tabs: [
                        Tab(icon: Icon(Icons.token), text: 'Tokens'),
                        Tab(icon: Icon(Icons.image), text: 'NFT'),
                        Tab(icon: Icon(Icons.history), text: 'Activity'),
                        Tab(icon: Icon(Icons.settings), text: 'Settings'),
                      ],
                    ),
                    SizedBox(
                      height: 200, // Adjust height as needed
                      child: TabBarView(
                        children: [
                          _buildTokensTab(),
                          _buildNFTTab(),
                          _buildActivityTab(),
                          _buildSettingsTab(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWalletActionButton(String text, IconData icon) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(12.0),
          child: Icon(icon, color: Colors.blue),
        ),
        const SizedBox(height: 5),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildTokensTab() {
    return ListView.builder(
      itemCount: 2, // Placeholder for two token entries
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.grey,
              child: Text('T'), // Placeholder for token icon
            ),
            title: Text('Token Name ${index + 1}'),
            subtitle: const Text('Amount: 0.00'),
            trailing: const Text('\$0.00'),
          ),
        );
      },
    );
  }

  Widget _buildNFTTab() {
    return const Center(child: Text('NFTs will be displayed here.'));
  }

  Widget _buildActivityTab() {
    return const Center(child: Text('Recent activity will be displayed here.'));
  }

  Widget _buildSettingsTab() {
    return const Center(child: Text('Wallet settings will be configured here.'));
  }
}

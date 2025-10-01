import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/design_tokens.dart';
import '../providers/app_state_provider.dart' as app_state_providers; // Import AppStateProvider with a prefix
import '../widgets/floating_chatbot.dart';

class MainScreen extends StatefulWidget {
  final Widget child;

  const MainScreen({super.key, required this.child});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  late AnimationController _fabController;
  late Animation<double> _fabScaleAnimation;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      duration: DesignTokens.animationNormal,
      vsync: this,
    );
    _fabScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _fabController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    // Skip the center scan FAB (index 2)
    if (index == 2) return;
    
    final navigationProvider = context.read<app_state_providers.NavigationProvider>();
    final adjustedIndex = index > 2 ? index - 1 : index;
    
    navigationProvider.setSelectedIndex(adjustedIndex);
    
    // Navigate using GoRouter
    switch (adjustedIndex) {
      case 0:
        context.go('/main/home');
        break;
      case 1:
        context.go('/main/stats');
        break;
      case 2:
        context.go('/main/community');
        break;
      case 3:
        context.push('/wallet-section');
        break;
    }
  }

  void _onScanPressed() {
    _fabController.forward().then((_) {
      _fabController.reverse();
    });
    
    context.push('/scan');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Stack(
        children: [
          widget.child,
          const FloatingChatbot(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(theme),
      floatingActionButton: _buildScanFAB(theme),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
  
  Widget _buildBottomNavigationBar(ThemeData theme) {
    return Consumer<app_state_providers.NavigationProvider>(
      builder: (context, navigationProvider, child) {
        final isDark = theme.brightness == Brightness.dark;
        
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                blurRadius: 24,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            child: NavigationBar(
              selectedIndex: navigationProvider.selectedIndex >= 2 
                  ? navigationProvider.selectedIndex + 1 
                  : navigationProvider.selectedIndex,
              onDestinationSelected: _onItemTapped,
              elevation: 0,
              backgroundColor: theme.colorScheme.surface,
              surfaceTintColor: theme.colorScheme.surfaceTint,
              height: 80,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              indicatorColor: theme.colorScheme.secondaryContainer,
              indicatorShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              animationDuration: const Duration(milliseconds: 300),
              destinations: [
                NavigationDestination(
                  icon: Icon(
                    Icons.home_outlined,
                    size: 24,
                  ),
                  selectedIcon: Icon(
                    Icons.home_rounded,
                    size: 24,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                  label: 'Home',
                  tooltip: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(
                    Icons.bar_chart_outlined,
                    size: 24,
                  ),
                  selectedIcon: Icon(
                    Icons.bar_chart_rounded,
                    size: 24,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                  label: 'Stats',
                  tooltip: 'Statistics',
                ),
                // Empty space for FAB
                NavigationDestination(
                  icon: SizedBox(
                    width: 56,
                    height: 24,
                  ),
                  label: '',
                ),
                NavigationDestination(
                  icon: Icon(
                    Icons.people_outline_rounded,
                    size: 24,
                  ),
                  selectedIcon: Icon(
                    Icons.people_rounded,
                    size: 24,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                  label: 'Community',
                  tooltip: 'Community',
                ),
                NavigationDestination(
                  icon: Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 24,
                  ),
                  selectedIcon: Icon(
                    Icons.account_balance_wallet_rounded,
                    size: 24,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                  label: 'Wallet',
                  tooltip: 'Wallet',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  Widget _buildScanFAB(ThemeData theme) {
    return Hero(
      tag: 'scan_fab',
      child: AnimatedBuilder(
        animation: _fabScaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _fabScaleAnimation.value,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withOpacity(0.85),
                  ],
                ),
                borderRadius: BorderRadius.circular(36),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.4),
                    blurRadius: 16,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.2),
                    blurRadius: 32,
                    spreadRadius: 4,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _onScanPressed,
                  borderRadius: BorderRadius.circular(36),
                  splashColor: Colors.white.withOpacity(0.3),
                  highlightColor: Colors.white.withOpacity(0.1),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.qr_code_scanner_rounded,
                        color: theme.colorScheme.onPrimary,
                        size: 28,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'SCAN',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.onPrimary,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

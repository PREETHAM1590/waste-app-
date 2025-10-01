import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../core/design_tokens.dart';
import '../core/theme/app_theme.dart';
import '../widgets/shared/shared_widgets.dart';
import '../widgets/m3_components.dart';
import '../providers/app_state_provider.dart';
import '../services/user_stats_service.dart';
import '../widgets/shared/glass_card.dart' as glass;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appStateProvider, child) {
        final theme = Theme.of(context);
        final user = appStateProvider.currentUser;
        final userName = user?.fullName.split(' ').first ?? 'User';
        final isLoading = appStateProvider.isLoading;
        
        return Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.transparent,
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryBlue.withOpacity(0.05),
                  AppTheme.primaryPurple.withOpacity(0.03),
                  const Color(0xFFF2F2F7),
                ],
              ),
            ),
            child: appStateProvider.isAuthenticated 
                ? CustomScrollView(
                  slivers: [
                    _buildAppBar(theme, userName, isLoading),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: DesignTokens.paddingHorizontalMD,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: DesignTokens.space16),
                            
                            // Eco-Points and Achievements Cards
                            _buildStatsCards(user, isLoading),
                            
                            SizedBox(height: DesignTokens.space32),
                            
                            // Central Scan Button
                            _buildCentralScanButton(theme),
                            
                            SizedBox(height: DesignTokens.space32),
                            
                            // Quick Access Section
                            _buildQuickAccessSection(),
                            
                            SizedBox(height: DesignTokens.space24),
                            
            // Quick Access Grid
            _buildQuickAccessGrid(),
            
            SizedBox(height: DesignTokens.space24),
                            
                            // Recent Activity (if needed)
                            _buildRecentActivity(),
                            
                            SizedBox(height: DesignTokens.space96), // Bottom padding for FAB
                          ],
                        ),
                      ),
                    ),
                  ],
                )
                : _buildUnauthenticatedView(theme),
          ),
        );
      },
    );
  }
  Widget _buildAppBar(ThemeData theme, String userName, bool isLoading) {
    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: theme.colorScheme.surface.withOpacity(0.95),
      surfaceTintColor: theme.colorScheme.surfaceTint,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(
          left: 20,
          bottom: 16,
        ),
        title: isLoading
            ? M3ShimmerLoading(
                width: 140,
                height: 24,
                borderRadius: BorderRadius.circular(8),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back,',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    userName,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
      ),
      actions: [
        IconButton(
          icon: Badge(
            isLabelVisible: false,
            child: Icon(
              Icons.notifications_outlined,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          tooltip: 'Notifications',
          onPressed: () {
            M3Snackbar.show(
              context,
              message: 'No new notifications',
              icon: Icons.notifications_outlined,
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: IconButton(
            icon: CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                style: TextStyle(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            tooltip: 'Profile',
            onPressed: () {
              context.push('/profile');
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildStatsCards(dynamic user, bool isLoading) {
    if (isLoading || user == null) {
      return Row(
        children: [
          Expanded(child: _buildLoadingSkeleton()),
          SizedBox(width: DesignTokens.space16),
          Expanded(child: _buildLoadingSkeleton()),
        ],
      );
    }
    
    // Use StreamBuilder to get real-time stats from Firebase
    return StreamBuilder<UserStats>(
      stream: UserStatsService().getUserStatsStream(),
      builder: (context, snapshot) {
        final stats = snapshot.data ?? UserStats();
        final nextMilestone = _getNextMilestone(stats.ecoPoints);
        final progressToNextMilestone = _calculateProgress(stats.ecoPoints, nextMilestone);
        
        return Row(
          children: [
            Expanded(
              child: glass.GlassCard(
                padding: const EdgeInsets.all(20),
                borderRadius: AppTheme.cornerRadiusLarge,
                blur: 15,
                opacity: 0.25,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppTheme.successGreen, AppTheme.successGreen.withOpacity(0.7)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.successGreen.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.eco_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Eco-Points',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${stats.ecoPoints}',
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progressToNextMilestone,
                        backgroundColor: AppTheme.successGreen.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation(AppTheme.successGreen),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${nextMilestone - stats.ecoPoints} to next level',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.successGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: DesignTokens.space16),
            Expanded(
              child: glass.GlassCard(
                padding: const EdgeInsets.all(20),
                borderRadius: AppTheme.cornerRadiusLarge,
                blur: 15,
                opacity: 0.25,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppTheme.warningOrange, AppTheme.warningYellow],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.warningOrange.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.emoji_events_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Achievements',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${stats.achievementsUnlocked}/${stats.totalAchievements}',
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: stats.achievementProgress,
                        backgroundColor: AppTheme.warningOrange.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation(AppTheme.warningOrange),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'unlocked',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.warningOrange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  
  int _getNextMilestone(int currentPoints) {
    const milestones = [100, 250, 500, 1000, 2500, 5000, 10000];
    for (final milestone in milestones) {
      if (currentPoints < milestone) {
        return milestone;
      }
    }
    return currentPoints + 1000; // Default next milestone
  }
  
  double _calculateProgress(int currentPoints, int nextMilestone) {
    const milestones = [0, 100, 250, 500, 1000, 2500, 5000, 10000];
    int previousMilestone = 0;
    
    for (int i = 0; i < milestones.length; i++) {
      if (milestones[i] >= nextMilestone) {
        if (i > 0) {
          previousMilestone = milestones[i - 1];
        }
        break;
      }
    }
    
    if (nextMilestone == previousMilestone) {
      return 1.0;
    }
    
    return (currentPoints - previousMilestone) / (nextMilestone - previousMilestone);
  }
  
  Widget _buildCentralScanButton(ThemeData theme) {
    return Center(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          context.push('/scan');
        },
        child: Container(
          width: 220,
          height: 220,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBlue.withOpacity(0.3),
                blurRadius: 40,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.4),
                      Colors.white.withOpacity(0.2),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.4),
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppTheme.primaryBlue, AppTheme.primaryPurple],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryBlue.withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.qr_code_scanner_rounded,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [AppTheme.primaryBlue, AppTheme.primaryPurple],
                      ).createShader(bounds),
                      child: Text(
                        'Scan Waste',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Point camera at item',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildQuickAccessSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Quick Access',
          style: GoogleFonts.inter(
            fontSize: DesignTokens.headlineSmall.fontSize,
            fontWeight: FontWeight.w600,
            color: DesignTokens.textPrimary,
          ),
        ),
        WastewiseTextButton(
          text: 'View All',
          onPressed: () {
            context.go('/main/community');
          },
          fontSize: DesignTokens.bodyMedium.fontSize,
        ),
      ],
    );
  }
  
  Widget _buildQuickAccessGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: DesignTokens.space16,
      crossAxisSpacing: DesignTokens.space16,
      childAspectRatio: 1.5,
      children: [
        _buildGlassQuickAction(
          'WiseBot',
          'AI Assistant',
          Icons.smart_toy_rounded,
          [AppTheme.primaryBlue, const Color(0xFF00C9FF)],
          () {
            HapticFeedback.lightImpact();
            context.push('/wisebot');
          },
        ),
        _buildGlassQuickAction(
          'Web3 Wallet',
          'Solana & tokens',
          Icons.account_balance_wallet_rounded,
          [const Color(0xFF8B5CF6), const Color(0xFFA855F7)],
          () {
            HapticFeedback.lightImpact();
            context.push('/wallet-section');
          },
        ),
        _buildGlassQuickAction(
          'Challenges',
          'Earn points',
          Icons.emoji_events_rounded,
          [AppTheme.warningOrange, AppTheme.warningYellow],
          () {
            HapticFeedback.lightImpact();
            context.push('/gamification');
          },
        ),
        _buildGlassQuickAction(
          'Community',
          'Learn & connect',
          Icons.people_rounded,
          [AppTheme.primaryPurple, const Color(0xFFEC4899)],
          () {
            HapticFeedback.lightImpact();
            context.go('/main/community');
          },
        ),
      ],
    );
  }

  Widget _buildGlassQuickAction(
    String title,
    String subtitle,
    IconData icon,
    List<Color> gradientColors,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: glass.GlassCard(
        padding: const EdgeInsets.all(10),
        borderRadius: AppTheme.cornerRadiusMedium,
        blur: 12,
        opacity: 0.25,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradientColors),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: gradientColors[0].withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: GoogleFonts.inter(
            fontSize: DesignTokens.headlineSmall.fontSize,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: DesignTokens.space16),
        glass.GlassCard(
          padding: const EdgeInsets.all(20),
          borderRadius: AppTheme.cornerRadiusMedium,
          blur: 12,
          opacity: 0.25,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.successGreen, AppTheme.successGreen.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.successGreen.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.recycling_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Plastic bottle recycled',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '+50 Eco-Points earned',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppTheme.successGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.textSecondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '2h ago',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildLoadingSkeleton() {
    return WastewiseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: DesignTokens.iconMD,
            height: DesignTokens.iconMD,
            decoration: BoxDecoration(
              color: DesignTokens.gray300,
              borderRadius: DesignTokens.borderRadiusXS,
            ),
          ),
          SizedBox(height: DesignTokens.space8),
          Container(
            width: double.infinity,
            height: 16,
            decoration: BoxDecoration(
              color: DesignTokens.gray300,
              borderRadius: DesignTokens.borderRadiusXS,
            ),
          ),
          SizedBox(height: DesignTokens.space4),
          Container(
            width: 80,
            height: 12,
            decoration: BoxDecoration(
              color: DesignTokens.gray200,
              borderRadius: DesignTokens.borderRadiusXS,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _testWalletConnection(BuildContext context) async {
    final appStateProvider = Provider.of<AppStateProvider>(context, listen: false);
    
    // Show dialog to get email for wallet generation
    final TextEditingController emailController = TextEditingController(text: 'test@example.com');
    
    final email = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Connect Wallet'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter email to generate wallet:'),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(emailController.text),
              child: const Text('Connect'),
            ),
          ],
        );
      },
    );
    
    if (email != null && email.isNotEmpty && email.contains('@')) {
      final success = await appStateProvider.authenticateWithWallet(email);
      
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Wallet connected successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to connect wallet: ${appStateProvider.errorMessage ?? 'Unknown error'}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  Widget _buildUnauthenticatedView(ThemeData theme) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 80),
            
            // App title with Material 3 styling
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                'Waste Wise',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            
            const SizedBox(height: 80),
            
            // Main content
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Welcome message
                  Text(
                    'Welcome to\nWaste Wise',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Description
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Join our community of eco-conscious individuals and start your journey towards a greener future.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Get Started button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: () {
                  context.push('/login');
                },
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 2,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.rocket_launch,
                      size: 20,
                      color: theme.colorScheme.onPrimary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Get Started',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Quick Test Wallet Connection
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _testWalletConnection(context),
                icon: const Icon(Icons.account_balance_wallet, size: 18),
                label: const Text('Quick Connect Wallet (Test)'),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

}

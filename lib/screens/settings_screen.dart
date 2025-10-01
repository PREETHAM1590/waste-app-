import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waste_classifier_flutter/providers/theme_provider.dart';
import 'package:waste_classifier_flutter/providers/app_state_provider.dart';
import 'package:waste_classifier_flutter/services/auth_service.dart';
import 'package:waste_classifier_flutter/widgets/m3_components.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final appStateProvider = Provider.of<AppStateProvider>(context);
    final user = appStateProvider.currentUser;
    final userName = user?.fullName ?? 'Guest User';
    final userEmail = user?.email ?? 'guest@wastewise.com';
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text('Settings'),
        elevation: 0,
        surfaceTintColor: theme.colorScheme.surfaceTint,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Card
          M3Card(
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.tertiary,
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : 'G',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userEmail,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    context.push('/profile');
                  },
                  icon: const Icon(Icons.edit_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.secondaryContainer,
                    foregroundColor: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // App Preferences Section
          M3SectionHeader(title: 'App Preferences'),
          const SizedBox(height: 8),
          
          M3ListTile(
            leadingIcon: Icons.notifications_rounded,
            title: 'Notifications',
            subtitle: 'Manage your alerts',
            trailing: Switch.adaptive(
              value: true,
              onChanged: (value) {
                M3Snackbar.show(
                  context,
                  message: 'Notifications ${value ? "enabled" : "disabled"}',
                  icon: Icons.check_circle_rounded,
                );
              },
            ),
          ),
          
          const SizedBox(height: 8),
          
          M3ListTile(
            leadingIcon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            title: 'Dark Mode',
            subtitle: isDark ? 'Enabled' : 'Disabled',
            trailing: Switch.adaptive(
              value: isDark,
              onChanged: (value) {
                themeProvider.toggleTheme(value);
                HapticFeedback.lightImpact();
              },
            ),
          ),
          
          const SizedBox(height: 8),
          
          M3ListTile(
            leadingIcon: Icons.language_rounded,
            title: 'Language',
            subtitle: 'English (US)',
            onTap: () {
              HapticFeedback.lightImpact();
              M3Snackbar.show(
                context,
                message: 'Language settings coming soon',
                icon: Icons.info_outline_rounded,
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          // Data & Privacy Section
          M3SectionHeader(title: 'Data & Privacy'),
          const SizedBox(height: 8),
          
          M3ListTile(
            leadingIcon: Icons.security_rounded,
            title: 'Privacy & Security',
            subtitle: 'Control your data',
            onTap: () {
              HapticFeedback.lightImpact();
            },
          ),
          
          const SizedBox(height: 8),
          
          M3ListTile(
            leadingIcon: Icons.storage_rounded,
            title: 'Data Usage',
            subtitle: 'Manage app data',
            onTap: () {
              HapticFeedback.lightImpact();
            },
          ),
          
          const SizedBox(height: 24),
          
          // About Section
          M3SectionHeader(title: 'About'),
          const SizedBox(height: 8),
          
          M3ListTile(
            leadingIcon: Icons.info_rounded,
            title: 'About Waste Wise',
            subtitle: 'Version 1.0.0',
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Waste Wise',
                applicationVersion: '1.0.0',
                applicationIcon: Icon(
                  Icons.recycling_rounded,
                  size: 48,
                  color: theme.colorScheme.primary,
                ),
              );
            },
          ),
          
          const SizedBox(height: 8),
          
          M3ListTile(
            leadingIcon: Icons.help_rounded,
            title: 'Help & Support',
            subtitle: 'Get help and feedback',
            onTap: () {
              HapticFeedback.lightImpact();
            },
          ),
          
          const SizedBox(height: 8),
          
          M3ListTile(
            leadingIcon: Icons.description_rounded,
            title: 'Terms of Service',
            onTap: () {
              HapticFeedback.lightImpact();
            },
          ),
          
          const SizedBox(height: 32),
          
          // Logout Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FilledButton.tonalIcon(
              onPressed: () async {
                final confirmed = await M3Dialog.showConfirmation(
                  context,
                  title: 'Sign Out',
                  message: 'Are you sure you want to sign out?',
                  confirmText: 'Sign Out',
                  cancelText: 'Cancel',
                );
                
                if (confirmed == true && context.mounted) {
                  try {
                    await AuthService().signOut();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  } catch (e) {
                    if (context.mounted) {
                      M3Snackbar.show(
                        context,
                        message: 'Failed to sign out',
                        icon: Icons.error_outline_rounded,
                        isError: true,
                      );
                    }
                  }
                }
              },
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Sign Out'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
                context,
                icon: Icons.palette_rounded,
                title: 'Theme',
                subtitle: themeProvider.themeMode == ThemeMode.dark ? 'Dark Mode' : 'Light Mode',
                gradientColors: [AppTheme.warningOrange, AppTheme.warningYellow],
                onTap: () {
                  HapticFeedback.lightImpact();
                  showDialog(
                    context: context,
                    builder: (context) => BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: AlertDialog(
                        backgroundColor: Colors.transparent,
                        contentPadding: EdgeInsets.zero,
                        content: GlassCard(
                          padding: const EdgeInsets.all(24),
                          borderRadius: AppTheme.cornerRadiusLarge,
                          blur: 30,
                          opacity: 0.3,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Select Theme',
                                style: GoogleFonts.inter(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 20),
                              GradientButton(
                                text: 'Light Mode',
                                icon: Icons.light_mode_rounded,
                                colors: [AppTheme.warningYellow, AppTheme.warningOrange],
                                onPressed: () {
                                  themeProvider.toggleTheme(false);
                                  Navigator.pop(context);
                                },
                              ),
                              const SizedBox(height: 12),
                              GradientButton(
                                text: 'Dark Mode',
                                icon: Icons.dark_mode_rounded,
                                colors: [AppTheme.primaryPurple, const Color(0xFF1E1E1E)],
                                onPressed: () {
                                  themeProvider.toggleTheme(true);
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              _buildSectionHeader(context, 'Personalization'),
              const SizedBox(height: 12),
              _buildGlassSettingsTile(
                context,
                icon: Icons.color_lens_rounded,
                title: 'Dynamic Theme',
                subtitle: 'Customize colors',
                gradientColors: [const Color(0xFFEC4899), const Color(0xFFF43F5E)],
                onTap: () {
                  HapticFeedback.lightImpact();
                },
              ),
              const SizedBox(height: 12),
              _buildGlassSettingsTile(
                context,
                icon: Icons.track_changes_rounded,
                title: 'Goals',
                subtitle: 'Set your targets',
                gradientColors: [AppTheme.successGreen, const Color(0xFF10B981)],
                onTap: () {
                  HapticFeedback.lightImpact();
                },
              ),
              const SizedBox(height: 24),
              _buildSectionHeader(context, 'Support & Information'),
              const SizedBox(height: 12),
              _buildGlassSettingsTile(
                context,
                icon: Icons.quiz_rounded,
                title: 'FAQ',
                subtitle: 'Get quick answers',
                gradientColors: [AppTheme.primaryBlue, AppTheme.primaryPurple],
                onTap: () {
                  HapticFeedback.lightImpact();
                },
              ),
              const SizedBox(height: 12),
              _buildGlassSettingsTile(
                context,
                icon: Icons.support_agent_rounded,
                title: 'Contact Support',
                subtitle: 'We\'re here to help',
                gradientColors: [const Color(0xFF8B5CF6), const Color(0xFFA855F7)],
                onTap: () {
                  HapticFeedback.lightImpact();
                },
              ),
              const SizedBox(height: 12),
              _buildGlassSettingsTile(
                context,
                icon: Icons.info_rounded,
                title: 'About Waste Wise',
                subtitle: 'Version 1.0.0',
                gradientColors: [AppTheme.warningOrange, AppTheme.warningYellow],
                onTap: () {
                  HapticFeedback.lightImpact();
                },
              ),
              const SizedBox(height: 24),
              // Logout Button
              GradientButton(
                text: 'Log Out',
                icon: Icons.logout_rounded,
                colors: [AppTheme.errorRed, AppTheme.errorPink],
                onPressed: () async {
                  HapticFeedback.mediumImpact();
                  final router = GoRouter.of(context);
                  await AuthService().signOut();
                  if (mounted) {
                    router.go('/login');
                  }
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppTheme.textPrimary,
        ),
      ),
    );
  }

  Widget _buildGlassSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> gradientColors,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        borderRadius: AppTheme.cornerRadiusMedium,
        blur: 20,
        opacity: 0.25,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
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
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.textSecondary,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

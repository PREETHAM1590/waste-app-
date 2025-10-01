import 'package:flutter/material.dart';
import 'package:waste_classifier_flutter/providers/theme_provider.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _challengeReminders = true;
  bool _communityUpdates = true;
  bool _educationalContent = false;
  bool _appUpdates = true;
  bool _enableAll = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notification Settings',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            
            // Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'Control what notifications you receive to stay informed without being overwhelmed.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textLight,
                  height: 1.5,
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            // Notification toggles
            _buildToggleTile(
              context,
              title: 'Challenge Reminders',
              subtitle: 'Get alerts for daily or weekly challenges to boost your eco-score.',
              value: _challengeReminders,
              onChanged: (value) {
                setState(() {
                  _challengeReminders = value;
                  _updateEnableAll();
                });
              },
            ),
            
            const SizedBox(height: 12),
            
            _buildToggleTile(
              context,
              title: 'Community Updates',
              subtitle: 'New posts in groups you\'ve joined and event announcements.',
              value: _communityUpdates,
              onChanged: (value) {
                setState(() {
                  _communityUpdates = value;
                  _updateEnableAll();
                });
              },
            ),
            
            const SizedBox(height: 12),
            
            _buildToggleTile(
              context,
              title: 'Educational Content',
              subtitle: 'Notifications for new articles, fun facts, and quizzes.',
              value: _educationalContent,
              onChanged: (value) {
                setState(() {
                  _educationalContent = value;
                  _updateEnableAll();
                });
              },
            ),
            
            const SizedBox(height: 12),
            
            _buildToggleTile(
              context,
              title: 'App Updates & Announcements',
              subtitle: 'Important news, feature updates, and special announcements from Waste Wise.',
              value: _appUpdates,
              onChanged: (value) {
                setState(() {
                  _appUpdates = value;
                  _updateEnableAll();
                });
              },
            ),
            
            const SizedBox(height: 32),
            
            _buildEnableAllCard(context),
            
            const SizedBox(height: 40),
            
            // Save button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // Save settings logic here
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Save Changes',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textLight,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Transform.scale(
                scale: 1.2,
                child: Switch(
                  value: value,
                  onChanged: onChanged,
                  activeThumbColor: AppColors.primary,
                  activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
                  inactiveThumbColor: Colors.grey.shade400,
                  inactiveTrackColor: Colors.grey.shade300,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnableAllCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enable All Notifications',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'One switch to rule them all.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 1.2,
            child: Switch(
              value: _enableAll,
              onChanged: (value) {
                setState(() {
                  _enableAll = value;
                  _challengeReminders = value;
                  _communityUpdates = value;
                  _educationalContent = value;
                  _appUpdates = value;
                });
              },
              activeThumbColor: AppColors.primary,
              activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
              inactiveThumbColor: Colors.grey.shade400,
              inactiveTrackColor: Colors.grey.shade300,
            ),
          ),
        ],
      ),
    );
  }

  void _updateEnableAll() {
    setState(() {
      _enableAll = _challengeReminders && _communityUpdates && _educationalContent && _appUpdates;
    });
  }
}

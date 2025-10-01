import 'package:flutter/material.dart';

class ShareAchievementsScreen extends StatelessWidget {
  const ShareAchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Achievements'),
      ),
      body: const Center(
        child: Text('Share Achievements Screen'),
      ),
    );
  }
}
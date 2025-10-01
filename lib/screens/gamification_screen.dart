import 'package:flutter/material.dart';

class GamificationScreen extends StatelessWidget {
  const GamificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gamification'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildLeaderboardCard(context),
          const SizedBox(height: 24),
          _buildAchievementBadgesCard(context),
          const SizedBox(height: 24),
          _buildWeeklyChallengeCard(context),
        ],
      ),
    );
  }

  Widget _buildLeaderboardCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Leaderboard', style: Theme.of(context).textTheme.headlineSmall),
                TextButton(onPressed: () {}, child: const Text('Community Ranking')),
              ],
            ),
            const SizedBox(height: 16),
            _buildLeaderboardEntry(context, 1, 'You', 'Eco-Warrior', '1,250', isYou: true),
            _buildLeaderboardEntry(context, 2, 'Jane Doe', 'Recycle Ranger', '1,180'),
            _buildLeaderboardEntry(context, 3, 'John Smith', 'Compost King', '1,150'),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardEntry(BuildContext context, int rank, String name, String title, String points, {bool isYou = false}) {
    return ListTile(
      leading: Text('$rank', style: Theme.of(context).textTheme.titleLarge),
      title: Text(name),
      subtitle: Text(title),
      trailing: Text('$points Eco-Points', style: const TextStyle(fontWeight: FontWeight.bold)),
      tileColor: isYou ? Theme.of(context).colorScheme.primary.withAlpha(25) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  Widget _buildAchievementBadgesCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Achievement Badges', style: Theme.of(context).textTheme.headlineSmall),
                Text('3/15', style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildBadge(context, 'Eco-Warrior', 'assets/images/badge1.png'),
                  _buildBadge(context, 'Recycle Ranger', 'assets/images/badge2.png'),
                  _buildBadge(context, 'Compost King', 'assets/images/badge3.png'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(BuildContext context, String name, String imagePath) {
    return SizedBox(
      width: 80,
      child: Column(
        children: [
          Image.asset(imagePath, height: 60),
          const SizedBox(height: 8),
          Text(name, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _buildWeeklyChallengeCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Weekly Challenge', style: Theme.of(context).textTheme.headlineSmall),
                const Text('+500 pts'),
              ],
            ),
            const SizedBox(height: 16),
            Text('Sort 20 items correctly this week!', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: 15 / 20,
              minHeight: 10,
              borderRadius: BorderRadius.circular(5),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text('15/20', style: Theme.of(context).textTheme.bodySmall),
            ),
          ],
        ),
      ),
    );
  }
}

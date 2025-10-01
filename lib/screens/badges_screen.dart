import 'package:flutter/material.dart';
import 'package:waste_classifier_flutter/models/badge.dart' as models;
import 'package:waste_classifier_flutter/services/badges_service.dart';

class BadgesScreen extends StatefulWidget {
  const BadgesScreen({super.key});

  @override
  BadgesScreenState createState() => BadgesScreenState();
}

class BadgesScreenState extends State<BadgesScreen> {
  final BadgesService _badgesService = BadgesService();
  late Stream<List<models.Badge>> _badges;

  @override
  void initState() {
    super.initState();
    _badges = _badgesService.getBadges();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Badges')),
      body: StreamBuilder<List<models.Badge>>(
        stream: _badges,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final badges = snapshot.data ?? [];
          if (badges.isEmpty) {
            return const Center(child: Text('No badges found.'));
          }
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
            itemCount: badges.length,
            itemBuilder: (context, index) {
              final badge = badges[index];
              return Card(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shield,
                      size: 50,
                      color: badge.isUnlocked ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      badge.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(badge.description),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Example: Add a new badge
          _badgesService.addBadge(models.Badge(name: 'New Badge', description: 'A newly added badge', isUnlocked: false));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

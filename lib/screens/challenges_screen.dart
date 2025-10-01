import 'package:flutter/material.dart';
import 'package:waste_classifier_flutter/models/challenge.dart';
import 'package:waste_classifier_flutter/services/challenges_service.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  ChallengesScreenState createState() => ChallengesScreenState();
}

class ChallengesScreenState extends State<ChallengesScreen> {
  final ChallengesService _challengesService = ChallengesService();
  late Stream<List<Challenge>> _challenges;

  @override
  void initState() {
    super.initState();
    _challenges = _challengesService.getChallenges();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Challenges')),
      body: StreamBuilder<List<Challenge>>(
        stream: _challenges,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final challenges = snapshot.data ?? [];
          if (challenges.isEmpty) {
            return const Center(child: Text('No challenges found.'));
          }
          return ListView.builder(
            itemCount: challenges.length,
            itemBuilder: (context, index) {
              final challenge = challenges[index];
              return ListTile(
                leading: Icon(
                  challenge.isCompleted
                      ? Icons.check_circle
                      : Icons.check_circle_outline,
                  color: challenge.isCompleted ? Colors.green : Colors.grey,
                ),
                title: Text(challenge.name),
                subtitle: Text(challenge.description),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Example: Add a new challenge
          _challengesService.addChallenge(Challenge(name: 'New Challenge', description: 'A newly added challenge', isCompleted: false));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

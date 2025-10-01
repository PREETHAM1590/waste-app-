import 'package:flutter/material.dart';
import 'package:waste_classifier_flutter/models/leaderboard_entry.dart';
import 'package:waste_classifier_flutter/services/leaderboard_service.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  LeaderboardScreenState createState() => LeaderboardScreenState();
}

class LeaderboardScreenState extends State<LeaderboardScreen> {
  final LeaderboardService _leaderboardService = LeaderboardService();
  late Stream<List<LeaderboardEntry>> _leaderboard;

  @override
  void initState() {
    super.initState();
    _leaderboard = _leaderboardService.getLeaderboardEntries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard')),
      body: StreamBuilder<List<LeaderboardEntry>>(
        stream: _leaderboard,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final entries = snapshot.data ?? [];
          if (entries.isEmpty) {
            return const Center(child: Text('No leaderboard entries found.'));
          }
          return ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              return ListTile(
                leading: Text('${index + 1}'),
                title: Text(entry.name),
                trailing: Text(entry.score.toString()),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Example: Add a new leaderboard entry
          _leaderboardService.addLeaderboardEntry(LeaderboardEntry(name: 'New Player', score: 100));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:waste_classifier_flutter/models/guideline.dart';
import 'package:waste_classifier_flutter/services/guidelines_service.dart';

class GuidelinesScreen extends StatefulWidget {
  const GuidelinesScreen({super.key});

  @override
  GuidelinesScreenState createState() => GuidelinesScreenState();
}

class GuidelinesScreenState extends State<GuidelinesScreen> {
  final GuidelinesService _guidelinesService = GuidelinesService();
  late Stream<List<Guideline>> _guidelines;

  @override
  void initState() {
    super.initState();
    _guidelines = _guidelinesService.getGuidelines();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Guidelines')),
      body: StreamBuilder<List<Guideline>>(
        stream: _guidelines,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final guidelines = snapshot.data ?? [];
          if (guidelines.isEmpty) {
            return const Center(child: Text('No guidelines found.'));
          }
          return ListView.builder(
            itemCount: guidelines.length,
            itemBuilder: (context, index) {
              final guideline = guidelines[index];
              return ListTile(
                title: Text(guideline.category),
                subtitle: Text(guideline.description),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Example: Add a new guideline
          _guidelinesService.addGuideline(Guideline(category: 'New Category', description: 'A newly added guideline'));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

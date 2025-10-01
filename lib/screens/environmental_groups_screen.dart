import 'package:flutter/material.dart';

class EnvironmentalGroupsScreen extends StatelessWidget {
  const EnvironmentalGroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Environmental Groups'),
      ),
      body: const Center(
        child: Text('Environmental Groups Screen'),
      ),
    );
  }
}
import 'package:flutter/material.dart';

class SocialImpactScreen extends StatelessWidget {
  const SocialImpactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Social Impact'),
      ),
      body: const Center(
        child: Text('Social Impact Screen'),
      ),
    );
  }
}
import 'package:flutter/material.dart';

class ReportIssueScreen extends StatefulWidget {
  const ReportIssueScreen({super.key});

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  String? _selectedIssueType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report an Issue'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type of Issue', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedIssueType,
              decoration: const InputDecoration(
                hintText: 'Select issue type',
              ),
              items: <String>[
                'Illegal Dumping',
                'Overflowing Bin',
                'Hazardous Spill',
                'E-waste',
                'Missed Collection',
                'Damaged Bin',
                'Other'
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedIssueType = newValue;
                });
              },
            ),
            const SizedBox(height: 24),
            Text('Location', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                hintText: 'Near 123 Green Way',
                prefixIcon: const Icon(Icons.location_on_outlined),
                suffixIcon: TextButton(
                  onPressed: () {},
                  child: const Text('Use GPS'),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Description', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const TextField(
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Provide details about the issue...',
              ),
            ),
            const SizedBox(height: 24),
            Text('Add Photo/Video', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildPhotoPlaceholder(context),
                const SizedBox(width: 16),
                _buildAddPhotoPlaceholder(context),
              ],
            ),
            const SizedBox(height: 24),
            _buildSmartDetectionCard(context),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Send Report'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoPlaceholder(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: const DecorationImage(
          image: AssetImage('assets/images/placeholder.png'), // Placeholder
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildAddPhotoPlaceholder(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: const Icon(Icons.add_a_photo_outlined),
    );
  }

  Widget _buildSmartDetectionCard(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer.withAlpha(128),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.lightbulb_outline, color: Theme.of(context).colorScheme.onSecondaryContainer),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Based on your location, this report will be sent to: Springfield Public Works Dept.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

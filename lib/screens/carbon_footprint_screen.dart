import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:waste_classifier_flutter/models/carbon_footprint_entry.dart';
import 'package:waste_classifier_flutter/services/carbon_footprint_service.dart';

class CarbonFootprintScreen extends StatefulWidget {
  const CarbonFootprintScreen({super.key});

  @override
  CarbonFootprintScreenState createState() => CarbonFootprintScreenState();
}

class CarbonFootprintScreenState extends State<CarbonFootprintScreen> {
  final CarbonFootprintService _carbonFootprintService =
      CarbonFootprintService();
  late Stream<List<CarbonFootprintEntry>> _carbonFootprintData;

  @override
  void initState() {
    super.initState();
    _carbonFootprintData = _carbonFootprintService.getCarbonFootprintEntries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carbon Footprint'),
      ),
      body: StreamBuilder<List<CarbonFootprintEntry>>(
        stream: _carbonFootprintData,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final entries = snapshot.data ?? [];
          if (entries.isEmpty) {
            return const Center(child: Text('No carbon footprint data found.'));
          }
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots: entries
                        .asMap()
                        .entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value.co2))
                        .toList(),
                    isCurved: true,
                    barWidth: 4,
                    color: Colors.green,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

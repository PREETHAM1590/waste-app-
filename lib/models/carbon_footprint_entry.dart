import 'package:cloud_firestore/cloud_firestore.dart';

class CarbonFootprintEntry {
  final DateTime date;
  final double co2;

  CarbonFootprintEntry({required this.date, required this.co2});

  factory CarbonFootprintEntry.fromFirestore(Map<String, dynamic> data) {
    return CarbonFootprintEntry(
      date: (data['date'] as Timestamp).toDate(),
      co2: data['co2'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'date': Timestamp.fromDate(date),
      'co2': co2,
    };
  }
}

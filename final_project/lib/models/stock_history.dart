
import 'package:cloud_firestore/cloud_firestore.dart';

class StockHistory {
  final DateTime date;
  final int quantityChange;
  final String type; // e.g., 'in', 'out', 'initial'

  StockHistory({
    required this.date,
    required this.quantityChange,
    required this.type,
  });

  factory StockHistory.fromMap(Map<String, dynamic> map) {
    return StockHistory(
      date: (map['date'] as Timestamp).toDate(),
      quantityChange: map['quantityChange'] ?? 0,
      type: map['type'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date),
      'quantityChange': quantityChange,
      'type': type,
    };
  }
}

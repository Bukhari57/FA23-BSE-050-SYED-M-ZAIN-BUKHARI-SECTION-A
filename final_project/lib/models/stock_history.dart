
class StockHistory {
  final DateTime date;
  final int quantityChange;
  final String type; // e.g., 'in', 'out', 'initial'

  StockHistory({
    required this.date,
    required this.quantityChange,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'quantityChange': quantityChange,
      'type': type,
    };
  }

  factory StockHistory.fromMap(Map<String, dynamic> map) {
    return StockHistory(
      date: DateTime.parse(map['date']),
      quantityChange: map['quantityChange'],
      type: map['type'],
    );
  }
}

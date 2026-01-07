
class StockHistory {
  final DateTime date;
  final int quantityChange;
  final String type; // e.g., 'in', 'out', 'initial'

  StockHistory({
    required this.date,
    required this.quantityChange,
    required this.type,
  });
}

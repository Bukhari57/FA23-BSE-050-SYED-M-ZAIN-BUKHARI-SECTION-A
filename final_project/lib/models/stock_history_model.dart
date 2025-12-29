enum StockMovement {
  stockIn,
  stockOut,
}

class StockHistory {
  final DateTime date;
  final StockMovement movement;
  final int quantity;

  StockHistory({
    required this.date,
    required this.movement,
    required this.quantity,
  });
}

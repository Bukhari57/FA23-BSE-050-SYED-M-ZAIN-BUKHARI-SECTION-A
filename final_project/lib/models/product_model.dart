import 'package:f2/models/stock_history_model.dart';

class Product {
  final String sku;
  final double price;
  final double cost;
  final String category;
  int quantity;
  List<StockHistory> stockHistory;

  Product({
    required this.sku,
    required this.price,
    required this.cost,
    required this.category,
    this.quantity = 0,
    List<StockHistory>? stockHistory,
  }) : stockHistory = stockHistory ?? [];
}

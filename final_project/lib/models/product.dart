
import 'package:final_project/models/stock_history.dart';

class Product {
  String sku;
  String name;
  double price;
  double cost;
  String category;
  int stock;
  List<StockHistory> stockHistory;

  Product({
    required this.sku,
    required this.name,
    required this.price,
    required this.cost,
    required this.category,
    required this.stock,
    this.stockHistory = const [],
  });
}


import 'package:final_project/models/stock_history.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  String? id;
  String sku;
  String name;
  double price;
  double cost;
  String category;
  int stock;
  List<StockHistory> stockHistory;

  Product({
    this.id,
    required this.sku,
    required this.name,
    required this.price,
    required this.cost,
    required this.category,
    required this.stock,
    this.stockHistory = const [],
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;;
    return Product(
      id: doc.id,
      sku: data['sku'] ?? '',
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      cost: (data['cost'] ?? 0).toDouble(),
      category: data['category'] ?? '',
      stock: data['stock'] ?? 0,
      stockHistory: (data['stockHistory'] as List? ?? []).map((history) => StockHistory.fromMap(history)).toList(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'sku': sku,
      'name': name,
      'price': price,
      'cost': cost,
      'category': category,
      'stock': stock,
      'stockHistory': stockHistory.map((history) => history.toMap()).toList(),
    };
  }
}

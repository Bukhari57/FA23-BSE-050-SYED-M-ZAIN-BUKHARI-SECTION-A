import 'package:final_project/models/product_model.dart';
import 'package:final_project/models/stock_history_model.dart';

final List<Product> mockProducts = [
  Product(
    sku: 'TS-BLK-L',
    price: 25.0,
    cost: 10.0,
    category: 'Apparel',
    quantity: 100,
    stockHistory: [
      StockHistory(date: DateTime.now(), movement: StockMovement.stockIn, quantity: 100)
    ]
  ),
  Product(
    sku: 'MUG-WHT',
    price: 15.0,
    cost: 5.0,
    category: 'Kitchenware',
    quantity: 50,
    stockHistory: [
      StockHistory(date: DateTime.now(), movement: StockMovement.stockIn, quantity: 50)
    ]
  ),
  Product(
    sku: 'HAT-RED',
    price: 20.0,
    cost: 7.0,
    category: 'Apparel',
    quantity: 75,
    stockHistory: [
      StockHistory(date: DateTime.now(), movement: StockMovement.stockIn, quantity: 75)
    ]
  ),
];

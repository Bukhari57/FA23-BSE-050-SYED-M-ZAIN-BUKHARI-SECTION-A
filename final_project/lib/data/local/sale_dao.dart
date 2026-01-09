import 'dart:convert';

import 'package:final_project/data/local/app_database.dart';
import 'package:final_project/data/local/product_dao.dart';
import 'package:final_project/models/cart_item.dart';
import 'package:final_project/models/product.dart';
import 'package:final_project/models/sale.dart';

class SaleDao {
  final productDao = ProductDao();

  Future<int> saveSale(Sale sale) async {
    final db = await AppDatabase.db;
    return await db.insert('sales', sale.toMap());
  }

  Future<List<Sale>> getSales() async {
    final db = await AppDatabase.db;
    final List<Map<String, dynamic>> maps = await db.query('sales');
    final List<Sale> sales = [];
    for (var map in maps) {
      final List<dynamic> itemMaps = jsonDecode(map['items']);
      final List<CartItem> items = [];
      for (var itemMap in itemMaps) {
        final Product? product = await productDao.getProduct(itemMap['productId']);
        if (product != null) {
          items.add(CartItem.fromMap(itemMap, product));
        }
      }
      sales.add(Sale.fromMap(map, items));
    }
    return sales;
  }

  Future<int> updateSale(Sale sale) async {
    final db = await AppDatabase.db;
    return await db.update(
      'sales',
      sale.toMap(),
      where: 'id = ?',
      whereArgs: [sale.id],
    );
  }
}

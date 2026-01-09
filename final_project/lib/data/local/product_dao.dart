import 'package:final_project/data/local/app_database.dart';
import 'package:final_project/models/product.dart';

class ProductDao {
  Future<int> saveProduct(Product product) async {
    final db = await AppDatabase.db;
    return await db.insert('products', product.toMap());
  }

  Future<Product?> getProduct(String id) async {
    final db = await AppDatabase.db;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Product.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Product>> getProducts() async {
    final db = await AppDatabase.db;
    final List<Map<String, dynamic>> maps = await db.query('products');
    return List.generate(maps.length, (i) {
      return Product.fromMap(maps[i]);
    });
  }

  Future<int> updateProduct(Product product) async {
    final db = await AppDatabase.db;
    return await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(String id) async {
    final db = await AppDatabase.db;
    return await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

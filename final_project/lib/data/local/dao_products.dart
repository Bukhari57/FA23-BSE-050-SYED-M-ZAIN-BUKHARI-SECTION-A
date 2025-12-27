
import 'app_database.dart';

class ProductDao {
  Future<void> insert(Map<String, dynamic> data) async {
    final db = await AppDatabase.db;
    await db.insert('products', data);
  }

  Future<List<Map<String, dynamic>>> getAll() async {
    final db = await AppDatabase.db;
    return db.query('products');
  }
}

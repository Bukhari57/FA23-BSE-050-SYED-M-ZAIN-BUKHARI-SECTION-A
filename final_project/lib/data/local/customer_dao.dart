import 'package:final_project/data/local/app_database.dart';
import 'package:final_project/models/customer.dart';

class CustomerDao {
  Future<int> saveCustomer(Customer customer) async {
    final db = await AppDatabase.db;
    return await db.insert('customers', customer.toMap());
  }

  Future<List<Customer>> getCustomers() async {
    final db = await AppDatabase.db;
    final List<Map<String, dynamic>> maps = await db.query('customers');
    return List.generate(maps.length, (i) {
      return Customer.fromMap(maps[i]);
    });
  }

  Future<int> updateCustomer(Customer customer) async {
    final db = await AppDatabase.db;
    return await db.update(
      'customers',
      customer.toMap(),
      where: 'id = ?',
      whereArgs: [customer.id],
    );
  }

  Future<int> deleteCustomer(String id) async {
    final db = await AppDatabase.db;
    return await db.delete(
      'customers',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

import 'package:final_project/data/local/app_database.dart';
import 'package:final_project/models/user.dart';

class OfflineUserDao {
  Future<int> saveUser(String name, String email, String password) async {
    final db = await AppDatabase.db;
    return await db.insert('offline_users', {
      'name': name,
      'email': email,
      'password': password,
    });
  }

  Future<Map<String, dynamic>?> getUser(String email, String password) async {
    final db = await AppDatabase.db;
    final List<Map<String, dynamic>> maps = await db.query(
      'offline_users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getOfflineUsers() async {
    final db = await AppDatabase.db;
    return await db.query('offline_users');
  }

  Future<void> deleteUser(int id) async {
    final db = await AppDatabase.db;
    await db.delete(
      'offline_users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

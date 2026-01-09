import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  static Database? _db;

  static Future<Database> get db async {
    _db ??= await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'smart_pos.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, v) async {
        await db.execute('''
          CREATE TABLE products(
            id TEXT PRIMARY KEY,
            sku TEXT,
            name TEXT,
            price REAL,
            cost REAL,
            category TEXT,
            stock INTEGER,
            stockHistory TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE sales(
            id TEXT PRIMARY KEY,
            date TEXT,
            subtotal REAL,
            discountAmount REAL,
            taxAmount REAL,
            total REAL,
            isSynced INTEGER DEFAULT 0
          )
        ''');

        await db.execute('''
          CREATE TABLE sale_items(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            saleId TEXT,
            productId TEXT,
            quantity INTEGER,
            priceOverride REAL,
            FOREIGN KEY (saleId) REFERENCES sales(id),
            FOREIGN KEY (productId) REFERENCES products(id)
          )
        ''');

        await db.execute('''
          CREATE TABLE offline_users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            email TEXT,
            password TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE customers(
            id TEXT PRIMARY KEY,
            name TEXT,
            phone TEXT,
            email TEXT,
            address TEXT
          )
        ''');
      },
    );
  }
}

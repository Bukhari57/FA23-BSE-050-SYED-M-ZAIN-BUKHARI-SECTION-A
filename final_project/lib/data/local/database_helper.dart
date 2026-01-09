import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'pos_database.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
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
  }
}

import 'package:sqflite/sqflite.dart';
import '../Model/product.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('pos.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // Inside DatabaseHelper class

  Future _createDB(Database db, int version) async {
    // 1. Products Table
    await db.execute('''
    CREATE TABLE products (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      sku TEXT NOT NULL,
      name TEXT NOT NULL,
      price REAL NOT NULL,
      cost REAL NOT NULL,
      category TEXT NOT NULL,
      stock INTEGER NOT NULL
    )
  ''');

    // 2. Stock History Table
    await db.execute('''
    CREATE TABLE stock_history (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      productId INTEGER,
      changeAmount INTEGER,
      type TEXT, 
      date TEXT,
      FOREIGN KEY (productId) REFERENCES products (id)
    )
  ''');

    // 3. Persistent Cart Table (New)
    await db.execute('''
    CREATE TABLE cart (
      productId INTEGER PRIMARY KEY,
      quantity INTEGER,
      runtimePrice REAL,
      FOREIGN KEY (productId) REFERENCES products (id)
    )
  ''');

    // 4. Sales Table (For Reports)
    await db.execute('''
    CREATE TABLE sales (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      subtotal REAL,
      tax REAL,
      discount REAL,
      total REAL,
      date TEXT
    )
  ''');

    // 5. Sale Items Table (Link products to a specific sale)
    await db.execute('''
    CREATE TABLE sale_items (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      saleId INTEGER,
      productId INTEGER,
      quantity INTEGER,
      priceAtSale REAL,
      FOREIGN KEY (saleId) REFERENCES sales (id)
    )
  ''');

    // 1. Customers Table
    await db.execute('''
  CREATE TABLE customers (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    phone TEXT NOT NULL,
    email TEXT,
    address TEXT,
    balance REAL DEFAULT 0.0,
    debtLimit REAL DEFAULT 1000.0 -- New Field
  )
''');

    // 2. Ledger Table (Transaction history for credit/payments)
    await db.execute('''
  CREATE TABLE ledger (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    customerId INTEGER,
    amount REAL,
    type TEXT, -- 'SALE' (Debt) or 'PAYMENT' (Credit)
    date TEXT,
    description TEXT,
    FOREIGN KEY (customerId) REFERENCES customers (id)
  )
  ''');
  }

  // ------------------ Product Methods ------------------

  // CRUD Operations
  Future<int> addProduct(Product product) async {
    final db = await instance.database;
    return await db.insert('products', product.toMap());
  }

  Future<List<Product>> getAllProducts() async {
    final db = await instance.database;
    final result = await db.query('products');
    return result.map((json) => Product.fromMap(json)).toList();
  }

  Future<int> updateProduct(Product product) async {
    final db = await instance.database;
    return await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(int id) async {
    final db = await instance.database;
    return await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  // ----------------------- Inventory History Methods -----------------------

  // Retrieves all stock movements for a specific product
  Future<List<Map<String, dynamic>>> getProductHistory(int productId) async {
    final db = await instance.database;
    return await db.query(
      'stock_history',
      where: 'productId = ?',
      whereArgs: [productId],
      orderBy: 'date DESC', // Newest records first
    );
  }

  // Records a stock transaction (In/Out) in the history table
  Future<int> addStockHistory(Map<String, dynamic> history) async {
    final db = await instance.database;
    return await db.insert('stock_history', history);
  }

  // --- Cart Persistence Methods ---

  Future<void> syncCartToDB(int productId, int qty, double price) async {
    final db = await instance.database;
    if (qty > 0) {
      await db.insert('cart', {
        'productId': productId,
        'quantity': qty,
        'runtimePrice': price,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } else {
      await db.delete('cart', where: 'productId = ?', whereArgs: [productId]);
    }
  }

  Future<List<Map<String, dynamic>>> getCartItems() async {
    final db = await instance.database;
    return await db.query('cart');
  }

  Future<void> clearCart() async {
    final db = await instance.database;
    await db.delete('cart');
  }

  // --- Dashboard Methods --- //

  // Fetch total sales for today
  Future<double> getTodaySales() async {
    final db = await instance.database;
    String today = DateTime.now().toString().substring(0, 10);
    final result = await db.rawQuery(
      "SELECT SUM(total) as total FROM sales WHERE date LIKE '$today%'",
    );
    return result.first['total'] != null
        ? (result.first['total'] as num).toDouble()
        : 0.0;
  }

  // Fetch monthly sales data for a bar chart
  Future<List<Map<String, dynamic>>> getMonthlySalesData() async {
    final db = await instance.database;
    // Grouping by date for the current month
    return await db.rawQuery('''
    SELECT SUBSTR(date, 1, 10) as day, SUM(total) as dailyTotal 
    FROM sales 
    GROUP BY day 
    ORDER BY day DESC LIMIT 30
  ''');
  }

  // Fetch sales based on a timeframe
  Future<List<Map<String, dynamic>>> getFilteredSales(String timeframe) async {
    final db = await instance.database;
    String query = "SELECT * FROM sales";
    String now = DateTime.now().toString().substring(0, 10);

    if (timeframe == "Daily") {
      query += " WHERE date LIKE '$now%'";
    } else if (timeframe == "Weekly") {
      query += " WHERE date >= date('now', '-7 days')";
    } else if (timeframe == "Monthly") {
      query += " WHERE date >= date('now', '-30 days')";
    }

    return await db.rawQuery("$query ORDER BY date DESC");
  }

  // Fetch items for a specific sale
  Future<List<Map<String, dynamic>>> getSaleItems(int saleId) async {
    final db = await instance.database;
    return await db.rawQuery(
      '''
    SELECT si.*, p.name 
    FROM sale_items si 
    JOIN products p ON si.productId = p.id 
    WHERE si.saleId = ?
  ''',
      [saleId],
    );
  }

  // Get low stock count for the dashboard
  Future<int> getLowStockCount() async {
    final db = await instance.database;
    final result = await db.rawQuery(
      "SELECT COUNT(*) as count FROM products WHERE stock <= 5",
    );
    return result.first['count'] as int;
  }

  Future<List<Map<String, dynamic>>> getAllSales() async {
    final db = await instance.database;
    return await db.query('sales', orderBy: 'date DESC');
  }

  Future<List<Product>> getLowStockProducts() async {
    final db = await instance.database;
    final result = await db.query('products', where: 'stock <= 5');
    return result.map((json) => Product.fromMap(json)).toList();
  }

  // --- Customer Methods --- //

  // Fetch all customers from the database
  Future<List<Map<String, dynamic>>> getAllCustomers() async {
    final db = await instance.database;
    return await db.query('customers', orderBy: 'name ASC');
  }

  // Add a new customer to the database
  Future<int> addCustomer(Map<String, dynamic> customer) async {
    final db = await instance.database;
    return await db.insert('customers', customer);
  }

  Future<int> deleteCustomer(int id) async {
    final db = await instance.database;
    return await db.delete('customers', where: 'id = ?', whereArgs: [id]);
  }

  // Inside DatabaseHelper class

  // Record a payment received from a customer
  Future<void> receivePayment(
    int customerId,
    double amount,
    String note,
  ) async {
    final db = await instance.database;
    await db.transaction((txn) async {
      // 1. Add to Ledger
      await txn.insert('ledger', {
        'customerId': customerId,
        'amount': amount,
        'type': 'PAYMENT',
        'date': DateTime.now().toString(),
        'description': note,
      });

      // 2. Update Customer Balance (Adding payment reduces debt)
      await txn.rawUpdate(
        'UPDATE customers SET balance = balance + ? WHERE id = ?',
        [amount, customerId],
      );
    });
  }

  // Fetch ledger history for a specific customer
  Future<List<Map<String, dynamic>>> getCustomerLedger(int customerId) async {
    final db = await instance.database;
    return await db.query(
      'ledger',
      where: 'customerId = ?',
      whereArgs: [customerId],
      orderBy: 'date DESC',
    );
  }

  // Records a transaction in the ledger and updates the customer's total balance
  Future<void> updateLedger(
    int customerId,
    double amount,
    String description,
  ) async {
    final db = await instance.database;

    // Use a transaction to ensure both operations succeed or both fail
    await db.transaction((txn) async {
      // 1. Insert the entry into the ledger table
      await txn.insert('ledger', {
        'customerId': customerId,
        'amount': amount, // Negative for debt (Sale), Positive for payment
        'type': amount < 0 ? 'SALE' : 'PAYMENT',
        'date': DateTime.now().toString(),
        'description': description,
      });

      // 2. Update the balance in the customers table
      // Balance = Current Balance + amount
      await txn.rawUpdate(
        'UPDATE customers SET balance = balance + ? WHERE id = ?',
        [amount, customerId],
      );
    });
  }

  // --- Sales & Checkout Methods ---

  Future<void> saveOrder(
    double sub,
    double tax,
    double disc,
    double total,
    List<Product> cartItems,
  ) async {
    final db = await instance.database;

    await db.transaction((txn) async {
      // 1. Insert into Sales Table
      int saleId = await txn.insert('sales', {
        'subtotal': sub,
        'tax': tax,
        'discount': disc,
        'total': total,
        'date': DateTime.now().toString(),
      });

      for (var item in cartItems) {
        // 2. Insert into Sale Items
        await txn.insert('sale_items', {
          'saleId': saleId,
          'productId': item.id,
          'quantity': item.cartQuantity,
          'priceAtSale': item.price,
        });

        // 3. Deduct Stock from Product Table
        await txn.rawUpdate(
          'UPDATE products SET stock = stock - ? WHERE id = ?',
          [item.cartQuantity, item.id],
        );

        // 4. Record Stock History (OUT)
        await txn.insert('stock_history', {
          'productId': item.id,
          'changeAmount': item.cartQuantity,
          'type': 'OUT',
          'date': DateTime.now().toString(),
        });
      }

      // 5. Clear Cart DB
      await txn.delete('cart');
    });
  }

  // ------------------ Backup & Restore Methods ------------------

  // Danger: Clears local data to make room for cloud backup
  Future<void> clearLocalData() async {
    final db = await instance.database;
    await db.delete('products');
    await db.delete('customers');
    await db.delete('sales');
    await db.delete('sale_items');
    await db.delete('ledger');
  }
}

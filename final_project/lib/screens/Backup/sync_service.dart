import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../SQFLite/database_helper.dart';

class SyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _uid = FirebaseAuth.instance.currentUser!.uid;

  // 1. Sync Products
  Future<void> syncProducts() async {
    final products = await DatabaseHelper.instance.getAllProducts();
    final batch = _firestore.batch(); // Use batch for faster uploading

    for (var product in products) {
      var ref = _firestore
          .collection('users')
          .doc(_uid)
          .collection('products')
          .doc(product.id.toString());
      batch.set(ref, product.toMap());
    }
    await batch.commit();
  }

  // 2. Sync Customers
  Future<void> syncCustomers() async {
    final customers = await DatabaseHelper.instance.getAllCustomers();
    final batch = _firestore.batch();

    for (var customer in customers) {
      var ref = _firestore
          .collection('users')
          .doc(_uid)
          .collection('customers')
          .doc(customer['id'].toString());
      batch.set(ref, customer);
    }
    await batch.commit();
  }

  // 3. Sync Sales (Reports)
  Future<void> syncSales() async {
    final sales = await DatabaseHelper.instance.getAllSales();
    final batch = _firestore.batch();

    for (var sale in sales) {
      var ref = _firestore
          .collection('users')
          .doc(_uid)
          .collection('sales')
          .doc(sale['id'].toString());
      batch.set(ref, sale);
    }
    await batch.commit();
  }

  // Comprehensive One-Tap Sync
  Future<void> fullSync() async {
    await syncProducts();
    await syncCustomers();
    await syncSales();
  }

  // lib/services/sync_service.dart

  Future<void> restoreEverything() async {
    final dbHelper = DatabaseHelper.instance;
    final sqliteDb = await dbHelper.database;

    // 1. Clear existing local data to avoid duplicates/conflicts
    await dbHelper.clearLocalData();

    // 2. Restore Products
    var productSnaps = await _firestore
        .collection('users')
        .doc(_uid)
        .collection('products')
        .get();
    for (var doc in productSnaps.docs) {
      await sqliteDb.insert('products', doc.data());
    }

    // 3. Restore Customers
    var customerSnaps = await _firestore
        .collection('users')
        .doc(_uid)
        .collection('customers')
        .get();
    for (var doc in customerSnaps.docs) {
      await sqliteDb.insert('customers', doc.data());
    }

    // 4. Restore Sales (Reports)
    var saleSnaps = await _firestore
        .collection('users')
        .doc(_uid)
        .collection('sales')
        .get();
    for (var doc in saleSnaps.docs) {
      await sqliteDb.insert('sales', doc.data());
    }
  }
}

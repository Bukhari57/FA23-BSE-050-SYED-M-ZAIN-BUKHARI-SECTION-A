
import 'package:final_project/data/local/customer_dao.dart';
import 'package:final_project/data/local/product_dao.dart';
import 'package:final_project/data/local/sale_dao.dart';
import 'package:final_project/data/remote/firebase_service.dart';

class SyncManager {
  final _productDao = ProductDao();
  final _saleDao = SaleDao();
  final _customerDao = CustomerDao();
  final _remote = FirebaseService();

  Future<void> syncProducts() async {
    final products = await _productDao.getProducts();
    for (var p in products) {
      await _remote.syncProduct(p.toMap());
    }
  }

  Future<void> syncSales() async {
    final sales = await _saleDao.getSales();
    for (var s in sales) {
      if (!s.isSynced) {
        await _remote.syncSale(s.toMap());
        s.isSynced = true;
        await _saleDao.updateSale(s);
      }
    }
  }

  Future<void> syncCustomers() async {
    final customers = await _customerDao.getCustomers();
    for (var c in customers) {
      await _remote.syncCustomer(c.toMap());
    }
  }
}

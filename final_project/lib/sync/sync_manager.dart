
import '../data/local/dao_products.dart';
// import '../data/remote/firebase_service.dart';

class SyncManager {
  final _local = ProductDao();
  // final _remote = FirebaseService();

  Future<void> syncProducts() async {
    // final products = await _local.getAll();
    // for (var p in products) {
    //   await _remote.syncProduct(p);
    // }
  }
}

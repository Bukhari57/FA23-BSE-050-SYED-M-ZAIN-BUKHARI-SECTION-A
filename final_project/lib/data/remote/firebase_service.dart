import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final _db = FirebaseFirestore.instance;

  Future<void> syncProduct(Map<String, dynamic> product) async {
    await _db.collection('products').doc(product['id']).set(product);
  }

  Future<void> syncSale(Map<String, dynamic> sale) async {
    await _db.collection('sales').doc(sale['id']).set(sale);
  }

  Future<void> syncCustomer(Map<String, dynamic> customer) async {
    await _db.collection('customers').doc(customer['id']).set(customer);
  }
}

//
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class FirebaseService {
//   final _db = FirebaseFirestore.instance;
//
//   Future<void> syncProduct(Map<String, dynamic> product) async {
//     await _db.collection('products').doc(product['id']).set(product);
//   }
// }

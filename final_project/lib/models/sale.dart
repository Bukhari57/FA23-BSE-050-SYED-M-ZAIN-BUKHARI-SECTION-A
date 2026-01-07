
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/models/cart_item.dart';

class Sale {
  String? id;
  final DateTime date;
  final List<CartItem> items;
  final double subtotal;
  final double discountAmount;
  final double taxAmount;
  final double total;

  Sale({
    this.id,
    required this.date,
    required this.items,
    required this.subtotal,
    required this.discountAmount,
    required this.taxAmount,
    required this.total,
  });

  factory Sale.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Sale(
      id: doc.id,
      date: (data['date'] as Timestamp).toDate(),
      items: (data['items'] as List).map((item) => CartItem.fromMap(item)).toList(),
      subtotal: (data['subtotal'] as num).toDouble(),
      discountAmount: (data['discountAmount'] as num).toDouble(),
      taxAmount: (data['taxAmount'] as num).toDouble(),
      total: (data['total'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'date': date,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'discountAmount': discountAmount,
      'taxAmount': taxAmount,
      'total': total,
    };
  }
}

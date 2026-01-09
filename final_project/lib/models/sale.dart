
import 'dart:convert';

import 'package:final_project/models/cart_item.dart';

class Sale {
  String? id;
  final DateTime date;
  final List<CartItem> items;
  final double subtotal;
  final double discountAmount;
  final double taxAmount;
  final double total;
  bool isSynced;

  Sale({
    this.id,
    required this.date,
    required this.items,
    required this.subtotal,
    required this.discountAmount,
    required this.taxAmount,
    required this.total,
    this.isSynced = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'items': jsonEncode(items.map((e) => e.toMap()).toList()),
      'subtotal': subtotal,
      'discountAmount': discountAmount,
      'taxAmount': taxAmount,
      'total': total,
      'isSynced': isSynced ? 1 : 0,
    };
  }

  factory Sale.fromMap(Map<String, dynamic> map, List<CartItem> items) {
    return Sale(
      id: map['id'],
      date: DateTime.parse(map['date']),
      items: items,
      subtotal: map['subtotal'],
      discountAmount: map['discountAmount'],
      taxAmount: map['taxAmount'],
      total: map['total'],
      isSynced: map['isSynced'] == 1,
    );
  }
}

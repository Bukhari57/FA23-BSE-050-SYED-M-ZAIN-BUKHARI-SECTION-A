
import 'package:final_project/models/cart_item.dart';

class Sale {
  final DateTime date;
  final List<CartItem> items;
  final double subtotal;
  final double discountAmount;
  final double taxAmount;
  final double total;

  Sale({
    required this.date,
    required this.items,
    required this.subtotal,
    required this.discountAmount,
    required this.taxAmount,
    required this.total,
  });
}

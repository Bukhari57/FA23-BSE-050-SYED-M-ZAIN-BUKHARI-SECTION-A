
import 'package:final_project/models/product.dart';

class CartItem {
  final Product product;
  int quantity;
  double? priceOverride; // For runtime price change

  CartItem({
    required this.product,
    this.quantity = 1,
    this.priceOverride,
  });

  double get itemTotal {
    return (priceOverride ?? product.price) * quantity;
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      product: Product.fromFirestore(map['product']),
      quantity: map['quantity'] ?? 1,
      priceOverride: (map['priceOverride'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'product': product.toFirestore(),
      'quantity': quantity,
      'priceOverride': priceOverride,
    };
  }
}

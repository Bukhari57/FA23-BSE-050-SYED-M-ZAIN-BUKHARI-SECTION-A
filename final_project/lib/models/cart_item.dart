
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

  Map<String, dynamic> toMap() {
    return {
      'productId': product.id,
      'quantity': quantity,
      'priceOverride': priceOverride,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map, Product product) {
    return CartItem(
      product: product,
      quantity: map['quantity'],
      priceOverride: map['priceOverride'],
    );
  }
}

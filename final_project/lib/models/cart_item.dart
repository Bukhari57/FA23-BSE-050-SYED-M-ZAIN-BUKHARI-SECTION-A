
import 'package:f3/models/product.dart';

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
}

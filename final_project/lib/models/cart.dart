
import 'package:f3/models/cart_item.dart';

class Cart {
  final List<CartItem> items = [];
  double discount = 0.0; // Percentage
  double tax = 0.0; // Percentage

  double get subtotal {
    return items.fold(0, (total, item) => total + item.itemTotal);
  }

  double get discountAmount {
    return subtotal * (discount / 100);
  }

  double get taxAmount {
    return (subtotal - discountAmount) * (tax / 100);
  }

  double get total {
    return subtotal - discountAmount + taxAmount;
  }

  void addItem(CartItem item) {
    final existingItemIndex = items.indexWhere((i) => i.product.sku == item.product.sku);
    if (existingItemIndex != -1) {
      items[existingItemIndex].quantity += item.quantity;
    } else {
      items.add(item);
    }
  }

  void removeItem(String sku) {
    items.removeWhere((item) => item.product.sku == sku);
  }

  void clear() {
    items.clear();
    discount = 0.0;
    tax = 0.0;
  }
}

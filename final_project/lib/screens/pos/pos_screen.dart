
import 'package:final_project/models/cart.dart';
import 'package:final_project/models/cart_item.dart';
import 'package:final_project/models/product.dart';
import 'package:flutter/material.dart';

class POSScreen extends StatefulWidget {
  final List<Product> products;
  final Function(Cart) onCheckout;

  const POSScreen({super.key, required this.products, required this.onCheckout});

  @override
  _POSScreenState createState() => _POSScreenState();
}

class _POSScreenState extends State<POSScreen> {
  final Cart cart = Cart();

  void _addToCart(Product product) {
    setState(() {
      cart.addItem(CartItem(product: product));
    });
  }

  void _incrementQuantity(CartItem item) {
    setState(() {
      item.quantity++;
    });
  }

  void _decrementQuantity(CartItem item) {
    setState(() {
      if (item.quantity > 1) {
        item.quantity--;
      }
    });
  }

  void _removeItem(CartItem item) {
    setState(() {
      cart.removeItem(item.product.sku);
    });
  }

  void _showPriceOverrideDialog(CartItem item) {
    final priceController = TextEditingController(text: item.priceOverride?.toString() ?? item.product.price.toString());
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Override Price'),
          content: TextField(
            controller: priceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'New Price'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  item.priceOverride = double.tryParse(priceController.text);
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showDiscountDialog() {
    final discountController = TextEditingController(text: cart.discount.toString());
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Set Discount (%)'),
          content: TextField(
            controller: discountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Discount'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  cart.discount = double.tryParse(discountController.text) ?? 0;
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showTaxDialog() {
    final taxController = TextEditingController(text: cart.tax.toString());
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Set Tax (%)'),
          content: TextField(
            controller: taxController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Tax'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  cart.tax = double.tryParse(taxController.text) ?? 0;
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('POS'),
      ),
      body: Row(
        children: [
          // Product List
          Expanded(
            flex: 2,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 3 / 2,
              ),
              itemCount: widget.products.length,
              itemBuilder: (context, index) {
                final product = widget.products[index];
                return Card(
                  child: InkWell(
                    onTap: () => _addToCart(product),
                    child: GridTile(
                      footer: GridTileBar(
                        backgroundColor: Colors.black45,
                        title: Text('\$${product.price}'),
                      ),
                      child: Center(child: Text(product.name)),
                    ),
                  ),
                );
              },
            ),
          ),

          // Cart
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              color: Colors.grey[200],
              child: Column(
                children: [
                  Text('Cart', style: Theme.of(context).textTheme.headlineSmall),
                  Expanded(
                    child: ListView.builder(
                      itemCount: cart.items.length,
                      itemBuilder: (context, index) {
                        final item = cart.items[index];
                        return Card(
                          child: ListTile(
                            title: Text(item.product.name),
                            subtitle: Text('\$${item.priceOverride ?? item.product.price}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(icon: const Icon(Icons.remove), onPressed: () => _decrementQuantity(item)),
                                Text(item.quantity.toString()),
                                IconButton(icon: const Icon(Icons.add), onPressed: () => _incrementQuantity(item)),
                                IconButton(icon: const Icon(Icons.edit), onPressed: () => _showPriceOverrideDialog(item)),
                                IconButton(icon: const Icon(Icons.delete), onPressed: () => _removeItem(item)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Subtotal'),
                    trailing: Text('\$${cart.subtotal.toStringAsFixed(2)}'),
                  ),
                  ListTile(
                    title: const Text('Discount'),
                    trailing: Text('\$${cart.discountAmount.toStringAsFixed(2)}'),
                    onTap: _showDiscountDialog,
                  ),
                  ListTile(
                    title: const Text('Tax'),
                    trailing: Text('\$${cart.taxAmount.toStringAsFixed(2)}'),
                    onTap: _showTaxDialog,
                  ),
                  ListTile(
                    title: Text('Total', style: Theme.of(context).textTheme.titleLarge),
                    trailing: Text('\$${cart.total.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleLarge),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      widget.onCheckout(cart);
                      cart.clear();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Checkout'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

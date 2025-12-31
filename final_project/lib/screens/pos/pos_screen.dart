
import 'package:f3/models/cart.dart';
import 'package:f3/models/cart_item.dart';
import 'package:f3/models/product.dart';
import 'package:flutter/material.dart';

class POSScreen extends StatefulWidget {
  final List<Product> products;
  final Function(Cart) onCheckout;

  POSScreen({required this.products, required this.onCheckout});

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
    final _priceController = TextEditingController(text: item.priceOverride?.toString() ?? item.product.price.toString());
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Override Price'),
          content: TextField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'New Price'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  item.priceOverride = double.tryParse(_priceController.text);
                });
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showDiscountDialog() {
    final _discountController = TextEditingController(text: cart.discount.toString());
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Set Discount (%)'),
          content: TextField(
            controller: _discountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Discount'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  cart.discount = double.tryParse(_discountController.text) ?? 0;
                });
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showTaxDialog() {
    final _taxController = TextEditingController(text: cart.tax.toString());
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Set Tax (%)'),
          content: TextField(
            controller: _taxController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Tax'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  cart.tax = double.tryParse(_taxController.text) ?? 0;
                });
                Navigator.pop(context);
              },
              child: Text('Save'),
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
        title: Text('POS'),
      ),
      body: Row(
        children: [
          // Product List
          Expanded(
            flex: 2,
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
                      child: Center(child: Text(product.name)),
                      footer: GridTileBar(
                        backgroundColor: Colors.black45,
                        title: Text('\$${product.price}'),
                      ),
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
              padding: EdgeInsets.all(8.0),
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
                                IconButton(icon: Icon(Icons.remove), onPressed: () => _decrementQuantity(item)),
                                Text(item.quantity.toString()),
                                IconButton(icon: Icon(Icons.add), onPressed: () => _incrementQuantity(item)),
                                IconButton(icon: Icon(Icons.edit), onPressed: () => _showPriceOverrideDialog(item)),
                                IconButton(icon: Icon(Icons.delete), onPressed: () => _removeItem(item)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Divider(),
                  ListTile(
                    title: Text('Subtotal'),
                    trailing: Text('\$${cart.subtotal.toStringAsFixed(2)}'),
                  ),
                  ListTile(
                    title: Text('Discount'),
                    trailing: Text('\$${cart.discountAmount.toStringAsFixed(2)}'),
                    onTap: _showDiscountDialog,
                  ),
                  ListTile(
                    title: Text('Tax'),
                    trailing: Text('\$${cart.taxAmount.toStringAsFixed(2)}'),
                    onTap: _showTaxDialog,
                  ),
                  ListTile(
                    title: Text('Total', style: Theme.of(context).textTheme.titleLarge),
                    trailing: Text('\$${cart.total.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleLarge),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      widget.onCheckout(cart);
                      cart.clear();
                      Navigator.pop(context);
                    },
                    child: Text('Checkout'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                    ),
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

import 'package:final_project/models/product_model.dart';
import 'package:final_project/models/stock_history_model.dart';
import 'package:final_project/screens/add_edit_product_screen.dart';
import 'package:final_project/screens/stock_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:final_project/models/mock_products.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({Key? key}) : super(key: key);

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final List<Product> _products = mockProducts;

  void _addProduct() async {
    final newProduct = await Navigator.push<Product>(
      context,
      MaterialPageRoute(builder: (context) => const AddEditProductScreen()),
    );
    if (newProduct != null) {
      setState(() {
        _products.add(newProduct);
      });
    }
  }

  void _editProduct(Product product) async {
    final updatedProduct = await Navigator.push<Product>(
      context,
      MaterialPageRoute(builder: (context) => AddEditProductScreen(product: product)),
    );
    if (updatedProduct != null) {
      setState(() {
        final index = _products.indexWhere((p) => p.sku == updatedProduct.sku);
        if (index != -1) {
          updatedProduct.stockHistory = _products[index].stockHistory;
          _products[index] = updatedProduct;
        }
      });
    }
  }

  void _deleteProduct(Product product) {
    setState(() {
      _products.remove(product);
    });
  }

  void _stockIn(Product product) {
    setState(() {
      product.quantity++;
      product.stockHistory.add(StockHistory(date: DateTime.now(), movement: StockMovement.stockIn, quantity: 1));
    });
  }

  void _stockOut(Product product) {
    setState(() {
      if (product.quantity > 0) {
        product.quantity--;
        product.stockHistory.add(StockHistory(date: DateTime.now(), movement: StockMovement.stockOut, quantity: 1));
      }
    });
  }

  void _viewStockHistory(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StockHistoryScreen(stockHistory: product.stockHistory)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
      ),
      body: ListView.builder(
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          final isLowStock = product.quantity < 5;
          return ListTile(
            title: Text(product.sku),
            subtitle: Text(product.category),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Qty: ${product.quantity}'),
                if (isLowStock)
                  const Icon(Icons.warning, color: Colors.red),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _stockIn(product),
                ),
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () => _stockOut(product),
                ),
                IconButton(
                  icon: const Icon(Icons.history),
                  onPressed: () => _viewStockHistory(product),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _editProduct(product),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteProduct(product),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addProduct,
        child: const Icon(Icons.add),
      ),
    );
  }
}

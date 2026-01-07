
import 'package:final_project/models/cart.dart';
import 'package:final_project/models/product.dart';
import 'package:final_project/models/sale.dart';
import 'package:final_project/models/stock_history.dart';
import 'package:final_project/screens/pos/pos_screen.dart';
import 'package:final_project/screens/product_management/add_product_screen.dart';
import 'package:final_project/screens/product_management/edit_product_screen.dart';
import 'package:final_project/screens/inventory_control/stock_in_out_screen.dart';
import 'package:final_project/screens/reports/sales_report_screen.dart';
import 'package:flutter/material.dart';

class ProductListScreen extends StatefulWidget {
  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final List<Product> products = [
    Product(
      sku: '123',
      name: 'Product 1',
      price: 10.0,
      cost: 5.0,
      category: 'Category 1',
      stock: 15, // Low stock example
      stockHistory: [
        StockHistory(date: DateTime.now(), quantityChange: 15, type: 'initial'),
      ],
    ),
    Product(
      sku: '456',
      name: 'Product 2',
      price: 20.0,
      cost: 10.0,
      category: 'Category 2',
      stock: 50,
      stockHistory: [
        StockHistory(date: DateTime.now(), quantityChange: 50, type: 'initial'),
      ],
    ),
  ];
  List<Sale> sales = [];
  List<Product> filteredProducts = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredProducts = products;
    searchController.addListener(() {
      filterProducts();
    });
  }

  void filterProducts() {
    List<Product> _products = [];
    _products.addAll(products);
    if (searchController.text.isNotEmpty) {
      _products.retainWhere((product) {
        String searchTerm = searchController.text.toLowerCase();
        String productName = product.name.toLowerCase();
        return productName.contains(searchTerm);
      });
    }
    setState(() {
      filteredProducts = _products;
    });
  }

  void _addProduct(Product product) {
    if (products.any((p) => p.sku == product.sku)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('SKU must be unique')),
      );
      return;
    }
    setState(() {
      product.stockHistory = [
        StockHistory(date: DateTime.now(), quantityChange: product.stock, type: 'initial'),
      ];
      products.add(product);
      filterProducts();
    });
  }

  void _editProduct(Product product) {
    setState(() {
      int index = products.indexWhere((p) => p.sku == product.sku);
      if (index != -1) {
        products[index] = product;
        filterProducts();
      }
    });
  }

  void _deleteProduct(Product product) {
    setState(() {
      products.removeWhere((p) => p.sku == product.sku);
      filterProducts();
    });
  }

  void _handleCheckout(Cart cart) {
    final newSale = Sale(
      date: DateTime.now(),
      items: cart.items,
      subtotal: cart.subtotal,
      discountAmount: cart.discountAmount,
      taxAmount: cart.taxAmount,
      total: cart.total,
    );
    sales.add(newSale);

    for (var item in cart.items) {
      final product = products.firstWhere((p) => p.sku == item.product.sku);
      final newStock = product.stock - item.quantity;
      final newHistory = StockHistory(
        date: DateTime.now(),
        quantityChange: -item.quantity,
        type: 'sale',
      );
      final updatedProduct = Product(
        sku: product.sku,
        name: product.name,
        price: product.price,
        cost: product.cost,
        category: product.category,
        stock: newStock,
        stockHistory: [newHistory, ...product.stockHistory],
      );
      _editProduct(updatedProduct);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product List'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
                final isLowStock = product.stock < 20;
                return Dismissible(
                  key: Key(product.sku),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    _deleteProduct(product);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${product.name} deleted')),
                    );
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  child: ListTile(
                    tileColor: isLowStock ? Colors.red.withOpacity(0.3) : null,
                    title: Text(product.name),
                    subtitle: Text(product.sku),
                    trailing: Text('Stock: ${product.stock}'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StockInOutScreen(
                            product: product,
                            onStockChanged: (newProduct) {
                              setState(() {
                                int index = products.indexWhere((p) => p.sku == newProduct.sku);
                                if (index != -1) {
                                  products[index] = newProduct;
                                  filterProducts();
                                }
                              });
                            },
                          ),
                        ),
                      );
                    },
                    onLongPress: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProductScreen(
                            product: product,
                            onEditProduct: _editProduct,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddProductScreen(
                    onAddProduct: _addProduct,
                  ),
                ),
              );
            },
            child: Icon(Icons.add),
            heroTag: null,
          ),
          SizedBox(width: 10),
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => POSScreen(
                    products: products,
                    onCheckout: _handleCheckout,
                  ),
                ),
              );
            },
            child: Icon(Icons.point_of_sale),
            heroTag: null,
          ),
          SizedBox(width: 10),
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SalesReportScreen(sales: sales),
                ),
              );
            },
            child: Icon(Icons.analytics),
            heroTag: null,
          ),
        ],
      ),
    );
  }
}

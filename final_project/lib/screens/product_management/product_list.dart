
import 'package:final_project/data/local/product_dao.dart';
import 'package:final_project/data/local/sale_dao.dart';
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
import 'package:uuid/uuid.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ProductDao _productDao = ProductDao();
  final SaleDao _saleDao = SaleDao();
  List<Product> products = [];
  List<Sale> sales = [];
  List<Product> filteredProducts = [];
  final TextEditingController searchController = TextEditingController();
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadSales();
    searchController.addListener(() {
      _filterProducts();
    });
  }

  Future<void> _loadProducts() async {
    final productList = await _productDao.getProducts();
    setState(() {
      products = productList;
      filteredProducts = productList;
    });
  }

  Future<void> _loadSales() async {
    final saleList = await _saleDao.getSales();
    setState(() {
      sales = saleList;
    });
  }

  void _filterProducts() {
    final searchTerm = searchController.text.toLowerCase();
    setState(() {
      filteredProducts = products
          .where((product) => product.name.toLowerCase().contains(searchTerm))
          .toList();
    });
  }

  void _addProduct(Product product) async {
    product.id = _uuid.v4();
    product.stockHistory = [
      StockHistory(date: DateTime.now(), quantityChange: product.stock, type: 'initial'),
    ];
    await _productDao.saveProduct(product);
    _loadProducts();
  }

  void _editProduct(Product product) async {
    await _productDao.updateProduct(product);
    _loadProducts();
  }

  void _deleteProduct(Product product) async {
    await _productDao.deleteProduct(product.id!);
    _loadProducts();
  }

  void _handleCheckout(Cart cart) async {
    final newSale = Sale(
      id: _uuid.v4(),
      date: DateTime.now(),
      items: cart.items,
      subtotal: cart.subtotal,
      discountAmount: cart.discountAmount,
      taxAmount: cart.taxAmount,
      total: cart.total,
    );
    await _saleDao.saveSale(newSale);
    _loadSales();

    for (var item in cart.items) {
      final product = products.firstWhere((p) => p.sku == item.product.sku);
      final newStock = product.stock - item.quantity;
      final newHistory = StockHistory(
        date: DateTime.now(),
        quantityChange: -item.quantity,
        type: 'sale',
      );
      final updatedProduct = Product(
        id: product.id,
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
        title: const Text('Product List'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
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
                  key: Key(product.id!),
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
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: const Icon(Icons.delete, color: Colors.white),
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
                              _editProduct(newProduct);
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
            heroTag: null,
            child: const Icon(Icons.add),
          ),
          const SizedBox(width: 10),
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
            heroTag: null,
            child: const Icon(Icons.point_of_sale),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SalesReportScreen(sales: sales),
                ),
              );
            },
            heroTag: null,
            child: const Icon(Icons.analytics),
          ),
        ],
      ),
    );
  }
}

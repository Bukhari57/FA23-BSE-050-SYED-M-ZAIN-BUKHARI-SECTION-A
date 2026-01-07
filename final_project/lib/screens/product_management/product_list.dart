
import 'package:cloud_firestore/cloud_firestore.dart';
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
  const ProductListScreen({super.key});

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<Product> allProducts = [];
  List<Product> filteredProducts = [];
  final TextEditingController searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    searchController.addListener(filterProducts);
  }

  @override
  void dispose() {
    searchController.removeListener(filterProducts);
    searchController.dispose();
    super.dispose();
  }

  void filterProducts() {
    final searchTerm = searchController.text.toLowerCase();
    setState(() {
      filteredProducts = allProducts.where((product) {
        return product.name.toLowerCase().contains(searchTerm);
      }).toList();
    });
  }

  void _addProduct(Product product) async {
    final existing = await _firestore.collection('products').where('sku', isEqualTo: product.sku).get();
    if (existing.docs.isNotEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('SKU must be unique')),
      );
      return;
    }

    product.stockHistory = [
      StockHistory(date: DateTime.now(), quantityChange: product.stock, type: 'initial'),
    ];
    await _firestore.collection('products').add(product.toFirestore());
  }

  void _editProduct(Product product) async {
    await _firestore.collection('products').doc(product.id).update(product.toFirestore());
  }

  void _deleteProduct(Product product) async {
    await _firestore.collection('products').doc(product.id).delete();
  }

  void _handleCheckout(Cart cart) async {
    final newSale = Sale(
      date: DateTime.now(),
      items: cart.items,
      subtotal: cart.subtotal,
      discountAmount: cart.discountAmount,
      taxAmount: cart.taxAmount,
      total: cart.total,
    );

    await _firestore.collection('sales').add(newSale.toFirestore());

    final batch = _firestore.batch();

    for (var item in cart.items) {
      final productRef = _firestore.collection('products').doc(item.product.id);
      final newStock = item.product.stock - item.quantity;
      final newHistory = StockHistory(
        date: DateTime.now(),
        quantityChange: -item.quantity,
        type: 'sale',
      );

      batch.update(productRef, {
        'stock': newStock,
        'stockHistory': FieldValue.arrayUnion([newHistory.toMap()]),
      });
    }
    await batch.commit();
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
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('products').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                allProducts = snapshot.data!.docs.map((doc) => Product.fromFirestore(doc)).toList();
                

                final searchTerm = searchController.text.toLowerCase();
                filteredProducts = allProducts.where((product) {
                  return product.name.toLowerCase().contains(searchTerm);
                }).toList();


                return ListView.builder(
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
            heroTag: 'addProduct',
            child: const Icon(Icons.add),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            onPressed: () {
               
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => POSScreen(
                    products: allProducts,
                    onCheckout: _handleCheckout,
                  ),
                ),
              );
            },
            heroTag: 'pos',
            child: const Icon(Icons.point_of_sale),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            onPressed: () {
              
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SalesReportScreen(),
                ),
              );
            },
            heroTag: 'reports',
            child: const Icon(Icons.analytics),
          ),
        ],
      ),
    );
  }
}

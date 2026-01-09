import 'package:flutter/material.dart';
import '../../Model/product.dart';
import '../../SQFLite/database_helper.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});
  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<Product> products = [];
  final List<String> _categories = [
    'General',
    'Electronics',
    'Grocery',
    'Clothing',
    'Stationery',
  ];
  String _selectedCategory = 'General';

  void refreshProducts() async {
    final data = await DatabaseHelper.instance.getAllProducts();
    setState(() => products = data);
  }

  @override
  void initState() {
    super.initState();
    refreshProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: Column(
        children: [
          // 2. Product List
          Expanded(
            child: products.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, i) =>
                        _buildModernProductCard(products[i]),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF004e92),
        onPressed: () => _showProductForm(null),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildModernProductCard(Product p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF004e92).withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.inventory_2_outlined,
            color: Color(0xFF004e92),
          ),
        ),
        title: Text(
          p.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              "SKU: ${p.sku} • Stock: ${p.stock}",
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                p.category,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "\$${p.price.toStringAsFixed(2)}",
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: Color(0xFF004e92),
                fontSize: 16,
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
        onTap: () => _showProductForm(p),
        onLongPress: () => _confirmDelete(p),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_shopping_cart, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text("No products found", style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  void _showProductForm(Product? product) {
    final nameCtrl = TextEditingController(text: product?.name ?? '');
    final skuCtrl = TextEditingController(text: product?.sku ?? '');
    final priceCtrl = TextEditingController(
      text: product?.price.toString() ?? '',
    );
    final costCtrl = TextEditingController(
      text: product?.cost.toString() ?? '',
    ); // Added cost field
    final stockCtrl = TextEditingController(
      text: product?.stock.toString() ?? '',
    );

    if (product != null) {
      _selectedCategory = product.category;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => StatefulBuilder(
        // Use StatefulBuilder to update dropdown state
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 25,
            right: 25,
            top: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  product == null ? "Add New Product" : "Edit Product",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF004e92),
                  ),
                ),
                const SizedBox(height: 20),

                // Name & SKU
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: "Product Name",
                    prefixIcon: Icon(Icons.shopping_bag_outlined),
                  ),
                ),
                TextField(
                  controller: skuCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "SKU / Barcode",
                    prefixIcon: Icon(Icons.qr_code),
                  ),
                ),

                const SizedBox(height: 15),

                // Category Dropdown
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  dropdownColor: Colors.white,
                  decoration: const InputDecoration(
                    labelText: "Category",
                    labelStyle: TextStyle(color: Colors.black),
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: _categories.map((String category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setModalState(() => _selectedCategory = value!);
                  },
                ),

                const SizedBox(height: 15),

                // Price & Cost Row
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: priceCtrl,
                        decoration: const InputDecoration(
                          labelText: "Sale Price",
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: TextField(
                        controller: costCtrl,
                        decoration: const InputDecoration(
                          labelText: "Cost Price",
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),

                TextField(
                  controller: stockCtrl,
                  decoration: const InputDecoration(
                    labelText: "Initial Stock Quantity",
                  ),
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 30),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF004e92),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    onPressed: () async {
                      final p = Product(
                        id: product?.id,
                        name: nameCtrl.text,
                        sku: skuCtrl.text,
                        price: double.tryParse(priceCtrl.text) ?? 0.0,
                        cost: double.tryParse(costCtrl.text) ?? 0.0,
                        category: _selectedCategory,
                        stock: int.tryParse(stockCtrl.text) ?? 0,
                      );

                      if (product == null) {
                        await DatabaseHelper.instance.addProduct(p);
                      } else {
                        await DatabaseHelper.instance.updateProduct(p);
                      }

                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                      refreshProducts();
                    },
                    child: const Text(
                      "Save Product",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(Product? product) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.red,
              size: 50,
            ),
            const SizedBox(height: 15),
            const Text(
              "Delete Customer?",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "Are you sure you want to remove ${product?.name}? This action cannot be undone.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 25),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "CANCEL",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () async {
                      if (product != null) {
                        await DatabaseHelper.instance.deleteProduct(
                          product.id!,
                        );
                      }
                      Navigator.pop(context);
                      refreshProducts(); // Refresh the list
                    },
                    child: const Text(
                      "DELETE",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}

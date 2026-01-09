import 'package:flutter/material.dart';
import '../../Model/product.dart';
import '../../SQFLite/database_helper.dart';
import 'stock_history_screen.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});
  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  List<Product> products = [];
  final int lowStockThreshold = 5;

  void refreshData() async {
    final data = await DatabaseHelper.instance.getAllProducts();
    setState(() => products = data);
  }

  @override
  void initState() {
    super.initState();
    refreshData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF004e92),
        leading: const BackButton(color: Colors.white),
        title: const Text(
          "Stock Control",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () {
              // General history logic if needed
            },
          ),
        ],
      ),
      body: products.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: products.length,
              itemBuilder: (context, i) => _buildModernInventoryTile(products[i]),
            ),
    );
  }

  Widget _buildModernInventoryTile(Product p) {
    bool isLowStock = p.stock <= lowStockThreshold;

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
          )
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isLowStock ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isLowStock ? Icons.warning_amber_rounded : Icons.check_circle_outline,
            color: isLowStock ? Colors.red : Colors.green,
          ),
        ),
        title: Text(
          p.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text("SKU: ${p.sku}", style: TextStyle(color: Colors.grey[600])),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "${p.stock}",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: isLowStock ? Colors.red : const Color(0xFF004e92),
              ),
            ),
            Text(
              isLowStock ? "LOW STOCK" : "IN STOCK",
              style: TextStyle(
                color: isLowStock ? Colors.red : Colors.green,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        onTap: () => _showStockUpdateSheet(p),
        onLongPress: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StockHistoryScreen(product: p),
            ),
          );
        },
      ),
    );
  }

  void _showStockUpdateSheet(Product p) {
    final amountCtrl = TextEditingController();

    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            Text("Quick Adjust: ${p.name}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 25),
            TextField(
              controller: amountCtrl,
              autofocus: true,
              decoration: InputDecoration(
                labelText: "Enter Quantity",
                prefixIcon: const Icon(Icons.add_business_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 25),
            Row(
              children: [
                Expanded(
                  child: _stockActionButton(
                    label: "STOCK OUT",
                    color: Colors.red,
                    icon: Icons.remove_circle_outline,
                    onPressed: () => _updateStock(p, int.tryParse(amountCtrl.text) ?? 0, "OUT"),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _stockActionButton(
                    label: "STOCK IN",
                    color: Colors.green,
                    icon: Icons.add_circle_outline,
                    onPressed: () => _updateStock(p, int.tryParse(amountCtrl.text) ?? 0, "IN"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _stockActionButton({required String label, required Color color, required IconData icon, required VoidCallback onPressed}) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text("No products found", style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  Future<void> _updateStock(Product p, int amount, String type) async {
    if (amount <= 0) return;
    int newStock = type == "IN" ? p.stock + amount : p.stock - amount;
    p.stock = newStock;
    await DatabaseHelper.instance.updateProduct(p);
    await DatabaseHelper.instance.addStockHistory({
      'productId': p.id,
      'changeAmount': amount,
      'type': type,
      'date': DateTime.now().toString(),
    });
    if (!mounted) return;
    Navigator.of(context).pop();
    refreshData();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text("Stock ${type == "IN" ? 'restocked' : 'deducted'} successfully"),
        backgroundColor: type == "IN" ? Colors.green : Colors.red,
      ),
    );
  }
}
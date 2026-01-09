import 'package:flutter/material.dart';
import '../../SQFLite/database_helper.dart';
import '../../Model/product.dart';

class LowStockReport extends StatelessWidget {
  const LowStockReport({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF004e92),
        leading: const BackButton(color: Colors.white),
        title: const Text(
          "Low Stock Alerts",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent),
          )
        ],
      ),
      body: FutureBuilder<List<Product>>(
        future: DatabaseHelper.instance.getLowStockProducts(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final products = snapshot.data!;
          if (products.isEmpty) {
            return _buildEmptyStockState();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryHeader(products.length),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: products.length,
                  itemBuilder: (context, i) => _buildLowStockCard(products[i]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryHeader(int count) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Text(
        "YOU HAVE $count ITEMS BELOW THRESHOLD",
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildLowStockCard(Product p) {
    // Assuming 10 is your threshold for the progress bar calculation
    double stockPercent = (p.stock / 10).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          // Visual warning indicator
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.red[50],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.priority_high, color: Colors.red[700], size: 20),
          ),
          const SizedBox(width: 16),
          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  "SKU: ${p.sku}",
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
                const SizedBox(height: 8),
                // Small stock bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: stockPercent,
                    minHeight: 4,
                    backgroundColor: Colors.grey[100],
                    color: p.stock <= 2 ? Colors.red : Colors.orange,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          // Stock Quantity Badge
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${p.stock}",
                style: TextStyle(
                  color: p.stock <= 2 ? Colors.red[900] : Colors.orange[900],
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Text(
                "UNITS",
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildEmptyStockState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 80, color: Colors.green[200]),
          const SizedBox(height: 16),
          const Text(
            "Inventory Healthy",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            "All items are above the minimum threshold.",
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
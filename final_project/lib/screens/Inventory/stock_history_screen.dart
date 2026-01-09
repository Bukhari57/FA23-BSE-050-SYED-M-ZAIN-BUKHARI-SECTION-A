import 'package:flutter/material.dart';
import '../../Model/product.dart';
import '../../SQFLite/database_helper.dart';

class StockHistoryScreen extends StatelessWidget {
  final Product product;

  const StockHistoryScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF004e92),
        leading: const BackButton(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Stock Audit Trail",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              product.name,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseHelper.instance.getProductHistory(product.id!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyHistory();
          }

          final history = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final item = history[index];
              final isStockIn = item['type'] == 'IN';

              return _buildHistoryItem(item, isStockIn);
            },
          );
        },
      ),
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> item, bool isStockIn) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: isStockIn ? Colors.green[50] : Colors.red[50],
          child: Icon(
            isStockIn ? Icons.south_west : Icons.north_east,
            color: isStockIn ? Colors.green : Colors.red,
            size: 18,
          ),
        ),
        title: Text(
          isStockIn ? "Stock Received" : "Stock Dispatched",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              "Date: ${item['date'].toString().substring(0, 16)}",
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isStockIn ? Colors.green[50] : Colors.red[50],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            "${isStockIn ? '+' : '-'}${item['changeAmount']}",
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
              color: isStockIn ? Colors.green[700] : Colors.red[700],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyHistory() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "No movements recorded yet",
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          Text(
            "Changes to stock will appear here.",
            style: TextStyle(color: Colors.grey[400], fontSize: 12),
          ),
        ],
      ),
    );
  }
}
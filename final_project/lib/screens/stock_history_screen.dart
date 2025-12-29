import 'package:f2/models/stock_history_model.dart';
import 'package:flutter/material.dart';

class StockHistoryScreen extends StatelessWidget {
  final List<StockHistory> stockHistory;

  const StockHistoryScreen({Key? key, required this.stockHistory}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock History'),
      ),
      body: ListView.builder(
        itemCount: stockHistory.length,
        itemBuilder: (context, index) {
          final history = stockHistory[index];
          return ListTile(
            title: Text('${history.movement == StockMovement.stockIn ? 'Stock In' : 'Stock Out'}'),
            subtitle: Text(history.date.toString()),
            trailing: Text('Quantity: ${history.quantity}'),
          );
        },
      ),
    );
  }
}

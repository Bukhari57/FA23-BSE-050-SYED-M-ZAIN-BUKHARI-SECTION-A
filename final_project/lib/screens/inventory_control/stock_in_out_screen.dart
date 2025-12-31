
import 'package:f3/models/product.dart';
import 'package:f3/models/stock_history.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StockInOutScreen extends StatefulWidget {
  final Product product;
  final Function(Product) onStockChanged;

  StockInOutScreen({required this.product, required this.onStockChanged});

  @override
  _StockInOutScreenState createState() => _StockInOutScreenState();
}

class _StockInOutScreenState extends State<StockInOutScreen> {
  final _quantityController = TextEditingController();

  void _updateStock(String type) {
    final quantity = int.tryParse(_quantityController.text);
    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid quantity')),
      );
      return;
    }

    setState(() {
      int newStock = widget.product.stock;
      if (type == 'in') {
        newStock += quantity;
      } else {
        if (quantity > widget.product.stock) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Cannot remove more stock than available')),
          );
          return;
        }
        newStock -= quantity;
      }

      final newHistory = StockHistory(
        date: DateTime.now(),
        quantityChange: type == 'in' ? quantity : -quantity,
        type: type,
      );

      final updatedProduct = Product(
        sku: widget.product.sku,
        name: widget.product.name,
        price: widget.product.price,
        cost: widget.product.cost,
        category: widget.product.category,
        stock: newStock,
        stockHistory: [newHistory, ...widget.product.stockHistory],
      );

      widget.onStockChanged(updatedProduct);
      _quantityController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current Stock: ${widget.product.stock}', style: TextStyle(fontSize: 20)),
            SizedBox(height: 20),
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _updateStock('in'),
                  child: Text('Stock In'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
                ElevatedButton(
                  onPressed: () => _updateStock('out'),
                  child: Text('Stock Out'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text('Stock History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: widget.product.stockHistory.length,
                itemBuilder: (context, index) {
                  final history = widget.product.stockHistory[index];
                  return ListTile(
                    leading: Icon(history.type == 'in' ? Icons.arrow_upward : Icons.arrow_downward),
                    title: Text('${history.quantityChange.abs()} units'),
                    subtitle: Text(DateFormat.yMd().add_jms().format(history.date)),
                    trailing: Text(history.type),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

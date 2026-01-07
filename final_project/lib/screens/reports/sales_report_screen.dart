
import 'package:final_project/models/sale.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SalesReportScreen extends StatelessWidget {
  final List<Sale> sales;

  const SalesReportScreen({Key? key, required this.sales}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sales Report'),
      ),
      body: ListView.builder(
        itemCount: sales.length,
        itemBuilder: (context, index) {
          final sale = sales[index];
          return Card(
            child: ListTile(
              title: Text('Sale on ${DateFormat.yMd().add_jms().format(sale.date)}'),
              subtitle: Text('Items: ${sale.items.length}'),
              trailing: Text('Total: \$${sale.total.toStringAsFixed(2)}'),
              onTap: () {
                // TODO: Navigate to Sale Detail Screen
              },
            ),
          );
        },
      ),
    );
  }
}

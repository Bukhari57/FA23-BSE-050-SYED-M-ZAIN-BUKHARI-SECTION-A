
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/models/sale.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SalesReportScreen extends StatelessWidget {
  const SalesReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Report'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('sales').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final sales = snapshot.data!.docs.map((doc) => Sale.fromFirestore(doc)).toList();

          return ListView.builder(
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
          );
        },
      ),
    );
  }
}

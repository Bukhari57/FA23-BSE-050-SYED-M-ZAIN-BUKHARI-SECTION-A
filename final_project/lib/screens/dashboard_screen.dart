
import 'package:flutter/material.dart';
import 'pos_screen.dart';
import 'product_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: ListView(
        children: [
          ListTile(title: const Text('POS'), onTap: () =>
            Navigator.push(context, MaterialPageRoute(builder: (_) => const POSScreen()))),
          ListTile(title: const Text('Products'), onTap: () =>
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductScreen()))),
        ],
      ),
    );
  }
}

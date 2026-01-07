import 'package:flutter/material.dart';

class StockReportScreen extends StatelessWidget {
  const StockReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Report'),
      ),
      body: const Center(
        child: Text('Stock Report Screen'),
      ),
    );
  }
}

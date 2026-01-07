import 'package:flutter/material.dart';

class CustomerReportScreen extends StatelessWidget {
  const CustomerReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Report'),
      ),
      body: const Center(
        child: Text('Customer Report Screen'),
      ),
    );
  }
}

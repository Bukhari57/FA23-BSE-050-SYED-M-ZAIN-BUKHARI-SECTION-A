import 'package:flutter/material.dart';

class DailyReportScreen extends StatelessWidget {
  const DailyReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Report'),
      ),
      body: const Center(
        child: Text('Daily Report Screen'),
      ),
    );
  }
}

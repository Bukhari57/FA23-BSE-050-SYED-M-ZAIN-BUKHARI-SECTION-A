import 'package:flutter/material.dart';
import '../../SQFLite/database_helper.dart';
import 'detailed_sales_resport.dart';
import 'low_stock_report.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});
  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  double todaySales = 0;
  int lowStock = 0;
  List<Map<String, dynamic>> customerData = [];
  List<Map<String, dynamic>> monthlyData = [];

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void _loadStats() async {
    double sales = await DatabaseHelper.instance.getTodaySales();
    int stock = await DatabaseHelper.instance.getLowStockCount();
    var customers = await DatabaseHelper.instance.getAllCustomers();
    var history = await DatabaseHelper.instance.getMonthlySalesData();
    setState(() {
      todaySales = sales;
      lowStock = stock;
      customerData = customers;
      monthlyData = history;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. Row of KPI Cards
          Row(
            children: [
              _buildKpiCard(
                "Today's Sales",
                "\$${todaySales.toStringAsFixed(2)}",
                Icons.analytics_outlined,
                Colors.blue,
                () => Navigator.push(context, MaterialPageRoute(builder: (c) => const DetailedSalesresport())),
              ),
              const SizedBox(width: 12),
              _buildKpiCard(
                "Stock Alerts",
                "$lowStock Items",
                Icons.inventory_2_outlined,
                lowStock > 0 ? Colors.orange : Colors.green,
                () => Navigator.push(context, MaterialPageRoute(builder: (c) => const LowStockReport())),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // 2. Debt Summary Section
          _sectionHeader("Debt Risk Analysis"),
          const SizedBox(height: 12),
          _buildCustomerDebtList(),

          const SizedBox(height: 24),

          // 3. Sales History Section
          _sectionHeader("Recent Daily Revenue"),
          const SizedBox(height: 12),
          _buildMonthlySalesList(),

          const SizedBox(height: 100), // Bottom spacing
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.grey[600],
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildKpiCard(String title, String value, IconData icon, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 16),
              Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
              Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerDebtList() {
    final debtors = customerData.where((c) => (c['balance'] as num).toDouble() < 0).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: debtors.isEmpty
          ? const Padding(padding: EdgeInsets.all(20), child: Center(child: Text("No high-risk debt detected")))
          : Column(
              children: debtors.take(5).map((c) {
                double debt = (c['balance'] as num).toDouble().abs();
                double limit = (c['debtLimit'] as num).toDouble();
                double percent = (debt / limit).clamp(0.0, 1.0);
                return ListTile(
                  title: Text(c['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percent,
                      minHeight: 4,
                      backgroundColor: Colors.grey[100],
                      color: percent > 0.8 ? Colors.red : Colors.blue,
                    ),
                  ),
                  trailing: Text("\$${debt.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.bold)),
                );
              }).toList(),
            ),
    );
  }

  Widget _buildMonthlySalesList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: monthlyData.isEmpty
          ? const Padding(padding: EdgeInsets.all(20), child: Center(child: Text("No sales data available")))
          : Column(
              children: monthlyData.map((data) {
                return ListTile(
                  leading: const Icon(Icons.show_chart, color: Colors.green, size: 20),
                  title: Text(data['day'], style: const TextStyle(fontSize: 14)),
                  trailing: Text(
                    "\$${data['dailyTotal'].toStringAsFixed(2)}",
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF004e92)),
                  ),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const DetailedSalesresport())),
                );
              }).toList(),
            ),
    );
  }
}
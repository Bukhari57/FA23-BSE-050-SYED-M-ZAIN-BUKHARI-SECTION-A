import 'package:flutter/material.dart';
import '../../SQFLite/database_helper.dart';

class DetailedSalesresport extends StatefulWidget {
  const DetailedSalesresport({super.key});
  @override
  State<DetailedSalesresport> createState() => _DetailedSalesresportState();
}

class _DetailedSalesresportState extends State<DetailedSalesresport> {
  String selectedFilter = "Monthly";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF004e92),
        leading: const BackButton(color: Colors.white),
        title: const Text(
          "Detailed Sales Report",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // 1. Modern Filter Bar
          _buildFilterBar(),

          // 2. Sales List
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: DatabaseHelper.instance.getFilteredSales(selectedFilter),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final sales = snapshot.data!;
                if (sales.isEmpty) {
                  return _buildEmptyHistory();
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: sales.length,
                  itemBuilder: (context, i) => _buildModernInvoiceCard(sales[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
      color: const Color(0xFF004e92),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            dropdownColor: const Color(0xFF004e92),
            value: selectedFilter,
            isExpanded: true,
            icon: const Icon(Icons.tune, color: Colors.white),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            items: ["Daily", "Weekly", "Monthly"].map((String val) {
              return DropdownMenuItem<String>(
                value: val,
                child: Text("$val Statistics"),
              );
            }).toList(),
            onChanged: (val) => setState(() => selectedFilter = val!),
          ),
        ),
      ),
    );
  }

  Widget _buildModernInvoiceCard(Map<String, dynamic> sale) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.receipt_long, color: Colors.green, size: 20),
          ),
          title: Text(
            "Invoice #${sale['id']}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          subtitle: Text(
            "${sale['date']}".substring(0, 16),
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          trailing: Text(
            "\$${sale['total'].toStringAsFixed(2)}",
            style: const TextStyle(
              color: Color(0xFF004e92),
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          children: [
            const Divider(height: 1),
            _buildInvoiceDetails(sale['id']),
            _buildSummaryRow(sale),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceDetails(int saleId) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: DatabaseHelper.instance.getSaleItems(saleId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const LinearProgressIndicator();

        return Container(
          padding: const EdgeInsets.all(16),
          color: const Color(0xFFFDFDFD),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("LINE ITEMS", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
              const SizedBox(height: 10),
              ...snapshot.data!.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Text("${item['quantity']}x", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                        const SizedBox(width: 10),
                        Expanded(child: Text(item['name'], style: const TextStyle(fontSize: 13))),
                        Text("\$${(item['quantity'] * item['priceAtSale']).toStringAsFixed(2)}", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryRow(Map<String, dynamic> sale) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _miniStat("Subtotal", "\$${sale['subtotal']}"),
          _miniStat("Tax", "\$${sale['tax']}"),
          _miniStat("Discount", "-\$${sale['discount']}", isRed: true),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value, {bool isRed = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isRed ? Colors.red : Colors.black87)),
      ],
    );
  }

  Widget _buildEmptyHistory() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text("No sales records found for this period", style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }
}
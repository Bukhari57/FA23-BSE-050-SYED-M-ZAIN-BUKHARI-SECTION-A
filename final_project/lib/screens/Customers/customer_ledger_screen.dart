import 'package:flutter/material.dart';
import '../../SQFLite/database_helper.dart';

class CustomerLedgerScreen extends StatefulWidget {
  final Map<String, dynamic> customer;
  const CustomerLedgerScreen({super.key, required this.customer});

  @override
  State<CustomerLedgerScreen> createState() => _CustomerLedgerScreenState();
}

class _CustomerLedgerScreenState extends State<CustomerLedgerScreen> {
  late double currentBalance;

  @override
  void initState() {
    super.initState();
    currentBalance = widget.customer['balance'] ?? 0.0;
  }

  void _refreshLedger() async {
    final customers = await DatabaseHelper.instance.getAllCustomers();
    final updatedCustomer = customers.firstWhere(
      (c) => c['id'] == widget.customer['id'],
    );
    setState(() {
      currentBalance = updatedCustomer['balance'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF004e92),
        leading: const BackButton(color: Colors.white),
        title: Text(
          "${widget.customer['name']}",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshLedger,
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Premium Balance Card
          _buildModernBalanceCard(),

          const Padding(
            padding: EdgeInsets.only(left: 20, top: 10, bottom: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "TRANSACTION HISTORY",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),

          // 2. Transaction List
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: _buildTransactionList(),
            ),
          ),

          // 3. Action Buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildModernBalanceCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF000428), Color(0xFF004e92)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF004e92).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Current Balance",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            "\$${currentBalance.toStringAsFixed(2)}",
            style: TextStyle(
              color: currentBalance < 0 ? Colors.redAccent[100] : Colors.greenAccent[400],
              fontSize: 32,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 15),
          const Divider(color: Colors.white24),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _infoTile("Phone", widget.customer['phone']),
              _infoTile("Status", currentBalance < 0 ? "Debt Owed" : "Cleared"),
            ],
          )
        ],
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildTransactionList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: DatabaseHelper.instance.getCustomerLedger(widget.customer['id']),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final logs = snapshot.data!;
        if (logs.isEmpty) {
          return Center(
            child: Text("No transactions yet", style: TextStyle(color: Colors.grey[400])),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 10),
          itemCount: logs.length,
          separatorBuilder: (context, index) => Divider(color: Colors.grey[100], height: 1),
          itemBuilder: (context, i) {
            final log = logs[i];
            bool isDebit = log['amount'] < 0;
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: isDebit ? Colors.red[50] : Colors.green[50],
                child: Icon(
                  isDebit ? Icons.arrow_upward : Icons.arrow_downward,
                  color: isDebit ? Colors.red : Colors.green,
                  size: 18,
                ),
              ),
              title: Text(
                log['description'] ?? "Transaction",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              subtitle: Text(
                log['date'].toString().substring(0, 10),
                style: const TextStyle(fontSize: 12),
              ),
              trailing: Text(
                "\$${log['amount'].abs().toStringAsFixed(2)}",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  color: isDebit ? Colors.red : Colors.green,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                onPressed: () => _showLedgerDialog(isPayment: false),
                icon: const Icon(Icons.remove_circle_outline),
                label: const Text("ADD DEBT", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                onPressed: () => _showLedgerDialog(isPayment: true),
                icon: const Icon(Icons.add_circle_outline),
                label: const Text("PAYMENT", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLedgerDialog({required bool isPayment}) {
    final amountCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(isPayment ? "Receive Payment" : "Add Manual Debt"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Amount",
                prefixText: "\$ ",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: descCtrl,
              decoration: InputDecoration(
                labelText: "Description",
                hintText: "e.g. Cash, Bill #1",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF004e92),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              if (amountCtrl.text.isEmpty) return;
              double amount = double.parse(amountCtrl.text);
              double finalAmount = isPayment ? amount : -amount;

              await DatabaseHelper.instance.updateLedger(
                widget.customer['id'],
                finalAmount,
                descCtrl.text.isEmpty
                    ? (isPayment ? "Manual Payment" : "Manual Debt")
                    : descCtrl.text,
              );

              if (!mounted) return;
              Navigator.pop(context);
              _refreshLedger();
            },
            child: const Text("Confirm", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
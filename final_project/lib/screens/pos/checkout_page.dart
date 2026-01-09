import 'package:flutter/material.dart';
import '../../SQFLite/database_helper.dart';
import '../../Model/product.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({
    super.key,
    required this.total,
    required this.subtotal,
    required this.tax,
    required this.globalDiscount,
    required this.cart,
  });

  final double total;
  final double subtotal;
  final double tax;
  final double globalDiscount;
  final Map<int, Product> cart;

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  int? selectedCustomerId;
  List<Map<String, dynamic>> customerList = [];
  bool isCreditSale = false;

  void loadCustomers() async {
    final data = await DatabaseHelper.instance.getAllCustomers();
    setState(() {
      customerList = data;
    });
  }

  @override
  void initState() {
    super.initState();
    loadCustomers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF004e92),
        leading: const BackButton(color: Colors.white),
        title: const Text(
          "Finalize Sale",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Total Summary Card
            _buildTotalCard(),
            
            const SizedBox(height: 30),
            const Text(
              "Customer Information",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            // 2. Customer Dropdown
            DropdownButtonFormField<int?>(
              dropdownColor: Colors.white,
              value: selectedCustomerId,
              decoration: _inputDecoration("Select Customer", Icons.person_search),
              items: [
                const DropdownMenuItem(value: null, child: Text("Walk-in (Cash Only)")),
                ...customerList.map((c) => DropdownMenuItem(
                      value: c['id'],
                      child: Text("${c['name']} (${c['phone']})"),
                    )),
              ],
              onChanged: (val) => setState(() {
                selectedCustomerId = val;
                if (val == null) isCreditSale = false;
              }),
            ),

            const SizedBox(height: 15),

            // 3. Conditional Fields
            if (selectedCustomerId != null) _buildCreditSaleToggle(),
            
            if (selectedCustomerId == null) ...[
              _simpleTextField("Customer Name", Icons.person_outline),
              _simpleTextField("Contact Number", Icons.phone_outlined),
              const Divider(height: 40),
              const Text("Payment Information", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _simpleTextField("Card Number", Icons.credit_card_outlined),
              Row(
                children: [
                  Expanded(child: _simpleTextField("MM/YY", Icons.calendar_month)),
                  const SizedBox(width: 15),
                  Expanded(child: _simpleTextField("CVV", Icons.lock_outline)),
                ],
              ),
            ],

            const SizedBox(height: 40),

            // 4. Confirm Button
            _buildPayButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF004e92), Color(0xFF0072FF)],
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
        children: [
          const Text("TOTAL PAYABLE", style: TextStyle(color: Colors.white70, letterSpacing: 1.2)),
          const SizedBox(height: 8),
          Text(
            "\$${widget.total.toStringAsFixed(2)}",
            style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          const Divider(color: Colors.white24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _smallInfo("Subtotal", "\$${widget.subtotal.toStringAsFixed(2)}"),
              _smallInfo("Discount", "-\$${widget.globalDiscount.toStringAsFixed(2)}"),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildCreditSaleToggle() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: isCreditSale ? Colors.orange.withOpacity(0.1) : Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: isCreditSale ? Colors.orange : Colors.transparent),
      ),
      child: SwitchListTile(
        title: const Text("Credit Sale", style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text("Post to customer ledger"),
        value: isCreditSale,
        activeColor: Colors.orange,
        onChanged: (val) => setState(() => isCreditSale = val),
      ),
    );
  }

  Widget _buildPayButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[700],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        onPressed: () async {
          // --- KEEP ORIGINAL LOGIC ---
          await DatabaseHelper.instance.saveOrder(
            widget.subtotal, widget.tax, widget.globalDiscount, widget.total, widget.cart.values.toList(),
          );
          if (isCreditSale) {
            await DatabaseHelper.instance.updateLedger(
              selectedCustomerId!, -widget.total, "POS Sale #${DateTime.now().millisecondsSinceEpoch}",
            );
          }
          // --- FEEDBACK ---
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Sale Finalized Successfully"), backgroundColor: Colors.green),
          );
          Navigator.popUntil(context, (route) => route.isFirst);
        },
        child: const Text(
          "COMPLETE TRANSACTION",
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.1),
        ),
      ),
    );
  }

  // --- HELPERS ---

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF004e92)),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade200)),
    );
  }

  Widget _simpleTextField(String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: TextField(decoration: _inputDecoration(label, icon)),
    );
  }

  Widget _smallInfo(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
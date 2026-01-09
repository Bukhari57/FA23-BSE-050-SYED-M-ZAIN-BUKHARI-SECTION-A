import 'package:flutter/material.dart';
import '../../SQFLite/database_helper.dart';
import 'customer_ledger_screen.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});
  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  List<Map<String, dynamic>> customers = [];
  final limitCtrl = TextEditingController(text: "1000");

  void refreshCustomers() async {
    final data = await DatabaseHelper.instance.getAllCustomers();
    setState(() => customers = data);
  }

  @override
  void initState() {
    super.initState();
    refreshCustomers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: customers.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: customers.length,
              itemBuilder: (context, i) => _buildModernCustomerCard(customers[i]),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF004e92),
        onPressed: () => _showCustomerForm(),
        child: const Icon(Icons.person_add_alt_1, color: Colors.white),
      ),
    );
  }

  Widget _buildModernCustomerCard(Map<String, dynamic> c) {
    double balance = (c['balance'] as num?)?.toDouble() ?? 0.0;
    double limit = (c['debtLimit'] as num?)?.toDouble() ?? 1000.0;
    double currentDebt = balance < 0 ? balance.abs() : 0.0;
    double percent = (currentDebt / limit).clamp(0.0, 1.0);
    bool isNearLimit = percent >= 0.8;
    bool isActuallyExceeded = percent >= 1.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActuallyExceeded ? Colors.red.withOpacity(0.5) : Colors.grey.shade200,
          width: isActuallyExceeded ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isActuallyExceeded ? Colors.red.withOpacity(0.05) : Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF004e92).withOpacity(0.1),
          child: Text(
            c['name'][0].toUpperCase(),
            style: const TextStyle(color: Color(0xFF004e92), fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          c['name'],
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(c['phone'] ?? "No Phone", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            if (balance < 0) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: percent,
                  minHeight: 6,
                  backgroundColor: Colors.grey[100],
                  color: isNearLimit ? Colors.red : Colors.green,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "${(percent * 100).toStringAsFixed(0)}% limit used",
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: isNearLimit ? Colors.red : Colors.grey[600]),
              ),
            ]
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "\$${balance.toStringAsFixed(2)}",
              style: TextStyle(
                color: balance < 0 ? Colors.red : Colors.green[700],
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            if (isActuallyExceeded)
              const Text(
                "OVER LIMIT",
                style: TextStyle(color: Colors.red, fontSize: 9, fontWeight: FontWeight.w900),
              ),
          ],
        ),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CustomerLedgerScreen(customer: c)),
          );
          refreshCustomers();
        },
        onLongPress: () => _confirmDelete(c),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text("No customers found", style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  void _showCustomerForm() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final _formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20, right: 20, top: 20,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
                const SizedBox(height: 20),
                const Text("New Customer", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                _formField(nameCtrl, "Full Name", Icons.person_outline),
                _formField(phoneCtrl, "Phone Number", Icons.phone_outlined, type: TextInputType.phone),
                _formField(emailCtrl, "Email Address", Icons.email_outlined, type: TextInputType.emailAddress),
                _formField(addressCtrl, "Address", Icons.location_on_outlined, maxLines: 2),
                _formField(limitCtrl, "Debt Limit (\$)", Icons.speed_rounded, type: TextInputType.number),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF004e92),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        await DatabaseHelper.instance.addCustomer({
                          'name': nameCtrl.text,
                          'phone': phoneCtrl.text,
                          'email': emailCtrl.text,
                          'address': addressCtrl.text,
                          'balance': 0.0,
                          'debtLimit': double.parse(limitCtrl.text),
                        });
                        if (!mounted) return;
                        Navigator.pop(context);
                        refreshCustomers();
                      }
                    },
                    child: const Text("SAVE CUSTOMER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _formField(TextEditingController ctrl, String label, IconData icon, {TextInputType type = TextInputType.text, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: ctrl,
        keyboardType: type,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF004e92)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
        ),
        validator: (val) => val!.isEmpty ? "Required" : null,
      ),
    );
  }

  void _confirmDelete(Map<String, dynamic> customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Delete Customer?"),
        content: Text("Delete ${customer['name']}? This cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await DatabaseHelper.instance.deleteCustomer(customer['id']);
              Navigator.pop(context);
              refreshCustomers();
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
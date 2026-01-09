import 'package:flutter/material.dart';
import '../../Model/product.dart';
import 'checkout_page.dart';
import '../../SQFLite/database_helper.dart';

class CartPage extends StatefulWidget {
  final Map<int, Product> cart;
  const CartPage({super.key, required this.cart});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  double taxRate = 0.05;
  double globalDiscount = 0.0;
  final TextEditingController _discountController = TextEditingController();

  double calculateSubtotal() {
    return widget.cart.values.fold(0, (sum, item) => sum + (item.price * item.cartQuantity));
  }

  @override
  Widget build(BuildContext context) {
    double subtotal = calculateSubtotal();
    double tax = subtotal * taxRate;
    double total = (subtotal + tax) - globalDiscount;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF004e92),
        leading: const BackButton(color: Colors.white),
        title: const Text("My Cart", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // 1. List of Items
          Expanded(
            child: widget.cart.isEmpty 
              ? _buildEmptyCart()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: widget.cart.length,
                  itemBuilder: (context, index) {
                    Product item = widget.cart.values.elementAt(index);
                    return _buildModernCartItem(item);
                  },
                ),
          ),

          // 2. Summary Panel
          _buildSummaryPanel(subtotal, tax, total),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_basket_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text("Your cart is empty", style: TextStyle(color: Colors.grey[600], fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildModernCartItem(Product item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Small Icon Box
          Container(
            height: 60, width: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF004e92).withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.inventory_2_outlined, color: Color(0xFF004e92)),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                GestureDetector(
                  onTap: () => _adjustPriceAtRuntime(item),
                  child: Text(
                    "\$${item.price.toStringAsFixed(2)}",
                    style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          // Stepper Logic
          Row(
            children: [
              _qtyBtn(Icons.remove, () => _decrement(item)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text("${item.cartQuantity}", style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              _qtyBtn(Icons.add, () => _increment(item)),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                onPressed: () => _removeItem(item),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }

  Widget _buildSummaryPanel(double sub, double tax, double total) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _summaryRow("Subtotal", "\$${sub.toStringAsFixed(2)}"),
            _summaryRow("Tax (5%)", "\$${tax.toStringAsFixed(2)}"),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Discount", style: TextStyle(color: Colors.grey)),
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: _discountController,
                    textAlign: TextAlign.right,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(hintText: "0.00", border: InputBorder.none),
                    onChanged: (val) => setState(() => globalDiscount = double.tryParse(val) ?? 0.0),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _summaryRow("Total", "\$${total.toStringAsFixed(2)}", isTotal: true),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF004e92),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => CheckoutPage(
                  total: total, subtotal: sub, tax: tax, globalDiscount: globalDiscount, cart: widget.cart,
                ))),
                child: const Text("PROCEED TO CHECKOUT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: isTotal ? 18 : 14, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontSize: isTotal ? 18 : 14, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, color: isTotal ? const Color(0xFF004e92) : Colors.black)),
        ],
      ),
    );
  }

  // --- REFACTORED LOGIC ---

  void _increment(Product item) async {
    if (item.cartQuantity < item.stock) {
      setState(() => item.cartQuantity++);
      await DatabaseHelper.instance.syncCartToDB(item.id!, item.cartQuantity, item.price);
    }
  }

  void _decrement(Product item) async {
    if (item.cartQuantity > 1) {
      setState(() => item.cartQuantity--);
      await DatabaseHelper.instance.syncCartToDB(item.id!, item.cartQuantity, item.price);
    }
  }

  void _removeItem(Product item) async {
    setState(() => widget.cart.remove(item.id));
    await DatabaseHelper.instance.syncCartToDB(item.id!, 0, item.price);
  }

  void _adjustPriceAtRuntime(Product item) {
    // Keep your existing dialog logic here, just style the buttons to match Color(0xFF004e92)
  }
}
import 'package:flutter/material.dart';
import '../../Model/product.dart';
import '../../SQFLite/database_helper.dart';
import 'cart_page.dart';

class POSSystemPage extends StatefulWidget {
  const POSSystemPage({super.key});
  @override
  State<POSSystemPage> createState() => _POSSystemPageState();
}

class _POSSystemPageState extends State<POSSystemPage> {
  List<Product> products = [];
  Map<int, Product> cart = {};

  void loadProducts() async {
    final data = await DatabaseHelper.instance.getAllProducts();
    setState(() => products = data);
  }

  @override
  void initState() {
    super.initState();
    loadProducts();
    loadCart();
  }

  // Inside _POSSystemPageState
  void loadCart() async {
    // 1. Fetch persistent cart rows from SQLite
    final List<Map<String, dynamic>> dbCart = await DatabaseHelper.instance
        .getCartItems();

    // 2. Clear existing local cart to avoid duplicates
    Map<int, Product> tempCart = {};

    for (var row in dbCart) {
      int pId = row['productId'];
      int qty = row['quantity'];
      double rPrice = row['runtimePrice'];

      // 3. Find the matching full Product object from our products list
      try {
        // Look for the product in the list we already fetched from the DB
        Product baseProduct = products.firstWhere((p) => p.id == pId);

        // 4. Update its temporary session fields
        baseProduct.cartQuantity = qty;
        baseProduct.price = rPrice; // Set the saved runtime price

        // 5. Add to the local Map
        tempCart[pId] = baseProduct;
      } catch (e) {
        print("Product $pId not found in local products list");
      }
    }

    // 6. Update the UI
    setState(() {
      cart = tempCart;
    });
  }

  // When adding to cart:
  void addToCart(Product p) async {
    setState(() {
      if (cart.containsKey(p.id)) {
        if (cart[p.id]!.cartQuantity < p.stock) {
          cart[p.id!]!.cartQuantity++;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Insufficient stock available"),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        p.cartQuantity = 1;
        cart[p.id!] = p;
      }
    });
    await DatabaseHelper.instance.syncCartToDB(p.id!, p.cartQuantity, p.price);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      // No more deep blue container header; we use the Tab Bar's AppBar
      body: Column(
        children: [
          // 1. Search and Category Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search products...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 2. Product Grid
          Expanded(
            child: products.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // 2 items per row
                      childAspectRatio: 0.85, 
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, i) => _buildProductCard(products[i]),
                  ),
          ),
        ],
      ),
      
      // 3. Floating Action Button (Matches the new theme)
      floatingActionButton: FloatingActionButton.extended(
        elevation: 4,
        backgroundColor: const Color(0xFF004e92),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (c) => CartPage(cart: cart)),
        ),
        label: Text(
          "Checkout (${cart.length})",
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        icon: const Icon(Icons.shopping_basket_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildProductCard(Product p) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Placeholder for Product Image or Icon
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Icon(Icons.image_outlined, color: Colors.grey.shade400, size: 40),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "\$${p.price}",
                      style: const TextStyle(
                        color: Color(0xFF004e92),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      "Stock: ${p.stock}",
                      style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => addToCart(p),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE3F2FD),
                      foregroundColor: const Color(0xFF004e92),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text("Add", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

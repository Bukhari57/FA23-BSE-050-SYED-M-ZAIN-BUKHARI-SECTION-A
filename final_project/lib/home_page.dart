import 'package:flutter/material.dart';
import 'Authentication/auth_service.dart';
import 'Screens/Product/product_list_screen.dart';
import 'Screens/POS/pos_system_page.dart';
import 'Screens/Customers/customer_list_screen.dart';
import 'Screens/Inventory/inventory_screen.dart';
import 'Screens/Report/reports_screen.dart';
import 'Screens/Backup/backup_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  AuthService get _authService => AuthService();

  // List of screens to display for each Tab
  final List<Widget> _pages = [
    const POSSystemPage(),
    const ProductListScreen(),
    const CustomerListScreen(),
    ReportsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- APP BAR ---
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              colors: [Color(0xFF000428), Color(0xFF004e92)],
            ),
          ),
        ),
        title: const Text(
          "Smart POS",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _authService.signOut(),
          ),
        ],
      ),

      // --- SIDE DRAWER (For secondary actions) ---
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: Column(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF004e92)),
              child: Center(
                child: Text(
                  "Management",
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.assessment),
              title: const Text("Inventory"),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const InventoryScreen())),
            ),
            ListTile(
              leading: const Icon(Icons.cloud_upload),
              title: const Text("Backup & Sync"),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => BackupScreen())),
            ),
          ],
        ),
      ),

      // --- DYNAMIC BODY ---
      body: _pages[_selectedIndex],

      // --- MODERN BOTTOM TAB BAR ---
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed, // Keeps labels visible
          selectedItemColor: const Color(0xFF004e92),
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'POS',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2),
              label: 'Products',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Customers',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: 'Reports',
            ),
          ],
        ),
      ),
    );
  }
}
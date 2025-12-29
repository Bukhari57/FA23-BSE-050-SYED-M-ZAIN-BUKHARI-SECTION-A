import 'package:f2/screens/add_edit_product_screen.dart';
import 'package:f2/screens/home_screen.dart';
import 'package:f2/screens/login_screen.dart';
import 'package:f2/screens/product_list_screen.dart';
import 'package:f2/screens/signup_screen.dart';
import 'package:f2/screens/splash_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => const HomeScreen(),
        '/products': (context) => const ProductListScreen(),
        '/add_edit_product': (context) => const AddEditProductScreen(),
      },
    );
  }
}

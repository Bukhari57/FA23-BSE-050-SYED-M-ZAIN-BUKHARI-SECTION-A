import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Authentication/login_screen.dart';
import 'Authentication/verify_email_screen.dart';
import 'home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    theme: ThemeData(
      primarySwatch: Colors.blue,
      textTheme: const TextTheme(
        bodyLarge: TextStyle(fontSize: 16.0, fontFamily: 'Lato'),
        bodyMedium: TextStyle(fontSize: 14.0, fontFamily: 'Lato'),
        titleLarge: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
      ),
    ),
    home: const AuthGate(),
    debugShowCheckedModeBanner: false,
  ));
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // USER IS LOGGED IN - Now check verification
          final user = snapshot.data!;
          if (user.emailVerified) {
            return const HomePage();
          } else {
            return const VerifyEmailScreen();
          }
        }
        // USER IS LOGGED OUT
        return const LoginScreen();
      },
    );
  }
}

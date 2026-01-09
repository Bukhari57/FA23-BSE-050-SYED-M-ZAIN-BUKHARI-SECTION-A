import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign Up
  Future<User?> signUp(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException {
      // Return the error code so we can handle it in the UI
      rethrow;
    } catch (e) {
      throw 'an-unknown-error';
    }
  }

  // Email Verification
  Future<void> sendEmailVerification(User user) async {
    try {
      await user.sendEmailVerification();
    } catch (e) {
      print(e.toString());
    }
  }

  // Login
  Future<User?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw 'an-unknown-error';
    }
  }

  // Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Forgot password
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}

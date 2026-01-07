import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/models/user.dart';

class AuthService {
  final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> signup(String name, String email, String password) async {
    try {
      final auth.UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final auth.User? firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        await _firestore.collection('users').doc(firebaseUser.uid).set({
          'name': name,
          'email': email,
        });
        return User(name: name, email: email, password: password, id: firebaseUser.uid);
      }
    } on auth.FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<User?> login(String email, String password) async {
    try {
      final auth.UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final auth.User? firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        final DocumentSnapshot userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();
        return User(
          id: firebaseUser.uid,
          name: userDoc.get('name'),
          email: userDoc.get('email'),
          password: '', // Password is not stored in Firestore
        );
      }
    } on auth.FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }
}

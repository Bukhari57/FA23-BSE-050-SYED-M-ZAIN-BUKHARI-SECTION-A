import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/data/local/offline_user_dao.dart';
import 'package:final_project/models/user.dart';
import 'package:final_project/services/connectivity_service.dart';

class AuthService {
  final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ConnectivityService _connectivityService = ConnectivityService();
  final OfflineUserDao _offlineUserDao = OfflineUserDao();

  Future<User?> signup(String name, String email, String password) async {
    if (await _connectivityService.isConnected()) {
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
          return User(id: firebaseUser.uid, name: name, email: email, password: password);
        }
      } on auth.FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          throw Exception('The password provided is too weak.');
        } else if (e.code == 'email-already-in-use') {
          throw Exception('An account already exists for that email.');
        } else {
          throw Exception('An error occurred during signup. Please try again.');
        }
      } catch (e) {
        throw Exception('An unknown error occurred.');
      }
    } else {
      await _offlineUserDao.saveUser(name, email, password);
      // Return a user object without an ID, since we're offline
      return User(name: name, email: email, password: password);
    }
    return null;
  }

  Future<User?> login(String email, String password) async {
    if (await _connectivityService.isConnected()) {
      try {
        final auth.UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        final auth.User? firebaseUser = userCredential.user;
        if (firebaseUser != null) {
          final userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();
          return User(
            id: firebaseUser.uid,
            name: userDoc.get('name'),
            email: userDoc.get('email'),
            password: '', // Password is not stored in Firestore
          );
        }
      } on auth.FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          throw Exception('No user found for that email.');
        } else if (e.code == 'wrong-password') {
          throw Exception('Wrong password provided for that user.');
        } else {
          throw Exception('An error occurred during login. Please try again.');
        }
      } catch (e) {
        throw Exception('An unknown error occurred.');
      }
    } else {
      final user = await _offlineUserDao.getUser(email, password);
      if (user != null) {
        return User(name: user['name'], email: user['email'], password: user['password']);
      }
    }
    return null;
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }
}

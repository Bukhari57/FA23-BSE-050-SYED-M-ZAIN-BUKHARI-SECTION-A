
import 'package:final_project/models/user.dart';

class AuthService {
  // Mock database table for users
  final List<User> _users = [];

  // Mock a singleton instance
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  Future<User?> signup(String name, String email, String password) async {
    // Check if user already exists
    if (_users.any((user) => user.email == email)) {
      return null; // Or throw an exception
    }
    final newUser = User(name: name, email: email, password: password);
    _users.add(newUser);
    return newUser;
  }

  Future<User?> login(String email, String password) async {
    // Find user in the mock database
    try {
      final user = _users.firstWhere(
        (user) => user.email == email && user.password == password,
      );
      return user;
    } catch (e) {
      return null;
    }
  }

  Future<void> logout() async {
    // In a real app, you would clear the session/token
    return;
  }
}

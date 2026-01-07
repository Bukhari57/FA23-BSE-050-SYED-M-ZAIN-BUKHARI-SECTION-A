
class User {
  final String name;
  final String email;
  final String password; // In a real app, this should be hashed

  User({required this.name, required this.email, required this.password});
}

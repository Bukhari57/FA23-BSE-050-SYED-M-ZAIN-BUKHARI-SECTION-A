
class User {
  String? id;
  final String name;
  final String email;
  final String password; // In a real app, this should be hashed

  User({this.id, required this.name, required this.email, required this.password});
}

class Product {
  int? id;
  String sku;
  String name;
  double price;
  double cost;
  String category;
  int stock;
  int cartQuantity = 0;
  double discount = 0.0;

  Product({
    this.id,
    required this.sku,
    required this.name,
    required this.price,
    required this.cost,
    required this.category,
    required this.stock,
  });

  // Convert for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sku': sku,
      'name': name,
      'price': price,
      'cost': cost,
      'category': category,
      'stock': stock,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      sku: map['sku'],
      name: map['name'],
      price: map['price'],
      cost: map['cost'],
      category: map['category'],
      stock: map['stock'],
    );
  }
}

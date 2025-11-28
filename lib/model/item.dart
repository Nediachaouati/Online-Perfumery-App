class Item {
  final int id;
  final String name;
  final double price;
  final String imgPath;
  final String description;

  Item({
    required this.id,
    required this.name,
    required this.price,
    required this.imgPath,
    required this.description,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] as int,
      name: json['title'] as String,
      price: (json['price'] as num).toDouble(),
      imgPath: json['thumbnail'] as String,
      description: json['description'] as String? ?? "No description available",
    );
  }
}
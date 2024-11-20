// menu_item_model.dart
class MenuItem {
  final int id;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;

  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'No Name',
      description: json['description'] ?? 'No Description',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      imageUrl: json['image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image_url': imageUrl,
    };
  }
}

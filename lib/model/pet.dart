class Pet {
  final String id;
  final String name;
  final String type;
  final String categoryId;
  final String description;
  final double price;
  final String image;
  
  Pet({
    required this.id,
    required this.name,
    required this.type,
    required this.categoryId,
    required this.description,
    required this.price,
    required this.image,
  });

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'].toString(),
      name: json['name'],
      type: json['type'],
      categoryId: json['category_id'].toString(),
      description: json['description'],
      price: double.parse(json['price'].toString()),
      image: json['image'],
    );
  }
} 
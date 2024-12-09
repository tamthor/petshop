class PetCategory {
  final int id;
  final String name;
  final String? description;
  final String? image;

  PetCategory({
    required this.id,
    required this.name,
    this.description,
    this.image,
  });

  factory PetCategory.fromJson(Map<String, dynamic> json) {
    return PetCategory(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      image: json['image'],
    );
  }
} 
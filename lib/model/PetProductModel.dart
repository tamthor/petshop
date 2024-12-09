class PetProduct {
   final String id;
  final String title;
  final int price;
  final String photo;
  final String summary;
  final String description;
  final String cat_id;
  final String stock;
  final String sold;
  
  PetProduct({
    required this.id,
    required this.title,
    required this.price,
    required this.photo,
    required this.summary,
    required this.description,
    required this.cat_id,
    required this.stock,
    required this.sold,
  });

  factory PetProduct.fromJson(Map<String, dynamic> json) {
    return PetProduct(
      id: json['id'].toString(),
      title: json['title'],
      price: json['price'],
      photo: json['photo'],
      summary: json['summary'],
      description: json['description'],
      cat_id: json['cat_id'].toString(),
      stock: json['stock'].toString(),
      sold: json['sold'].toString(),
    );
  }
  @override
  String toString() {
    return 'Product{name: $title, price: $price, image: $photo, summary: $summary, description: $description, cat_id: $cat_id, stock: $stock, sold: $sold}';
  }
} 
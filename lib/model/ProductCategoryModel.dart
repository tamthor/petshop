class PetProductCategory {
  final int id;
  final String title;
  final String slug;
  final String photo;
  final String status;

  PetProductCategory({
    required this.id,
    required this.title,
    required this.slug,
    required this.photo,
    required this.status,
  });

  // Tạo factory để parse từ JSON
  factory PetProductCategory.fromJson(Map<String, dynamic> json) {
    return PetProductCategory(
      id: json['id'],
      title: json['title'],
      slug: json['slug'],
      photo: json['photo'],
      status: json['status'],
    );
  }

  // Chuyển model sang JSON (nếu cần gửi dữ liệu lên server)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'slug': slug,
      'photo': photo,
      'status': status,
    };
  }
}

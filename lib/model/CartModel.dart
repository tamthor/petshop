class CartModel {
  int? id;
  int? userId;
  int? productId;
  

  CartModel({
    this.id,
    this.userId,
    this.productId,
   
  });

  // Từ JSON sang Model
  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      id: json['id'],
      userId: json['user_id'],
      productId: json['product_id'],
    );
  }

  // Từ Model sang JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'product_id': productId,
    };
  }
}
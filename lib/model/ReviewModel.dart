class ReviewModel {
  int? id;
  int? userId;
  int? productId;
  int? rating;
  String? comment;
  

  ReviewModel({
    this.id,
    this.userId,
    this.productId,
    this.rating,
    this.comment,
   
  });

  // Từ JSON sang Model
  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'],
      userId: json['user_id'],
      productId: json['product_id'],
      rating: json['rating'],
      comment: json['comment'],
     
    );
  }

  // Từ Model sang JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'product_id': productId,
      'rating': rating,
      'comment': comment,
    };
  }
}
class NotificationModel {
  int? id;
  int? userId;
  String? title;
  String? description;
  

  NotificationModel({
    this.id,
    this.userId,
    this.title,
    this.description,
   
  });

  // Từ JSON sang Model
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      description: json['description'],
     
    );
  }

  // Từ Model sang JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
    };
  }
}
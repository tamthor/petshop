import 'package:http/http.dart' as http;
import 'dart:convert';
import '../model/ReviewModel.dart';
import '../constant/apilist.dart';

class ReviewReponsitory {
  final apiUrl = api_add_review;

  // Tạo thông báo
  Future<ReviewModel?> createReview(ReviewModel reviews) async {
    final response = await http.post(
      Uri.parse('$api_add_review'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        },
      body: json.encode(reviews.toJson()),
    );

    // In ra phản hồi để kiểm tra
    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode == 201) {
      // Giải mã phản hồi
      final responseBody = json.decode(response.body);
      // Kiểm tra xem phản hồi có hợp lệ không
      if (responseBody != null) {
        // Tạo ReviewModel từ phản hồi
        return ReviewModel.fromJson(responseBody);
      } else {
        throw Exception('Response body is null');
      }
    } else {
      throw Exception('Failed to create review: ${response.statusCode} - ${response.body}');
    }
  }

  // Phương thức mới để theo dõi bình luận
  Stream<List<ReviewModel>> watchReviews(int productId) async* {
    while (true) {
      final reviews = await getReview(productId);
      yield reviews; // Phát ra danh sách bình luận
      await Future.delayed(Duration(seconds: 5)); // Thay đổi thời gian theo nhu cầu
    }
  }

  Future<List<ReviewModel>> getReview(int productId) async {
    final response = await http.get(
      Uri.parse('$api_get_review/$productId'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      final decodedBody = json.decode(response.body);

      // Kiểm tra xem response là Map hay List
      if (decodedBody is Map && decodedBody.containsKey('reviews')) {
        List<dynamic> jsonResponse = decodedBody['reviews'];
        return jsonResponse.map((json) => ReviewModel.fromJson(json)).toList();
      } else if (decodedBody is List) {
        // Nếu là danh sách
        return decodedBody.map((json) => ReviewModel.fromJson(json)).toList();
      } else {
        throw Exception('Unexpected JSON format: ${response.body}');
      }
    } else {
      throw Exception('Failed to load review: ${response.statusCode} - ${response.body}');
    }
  }
}

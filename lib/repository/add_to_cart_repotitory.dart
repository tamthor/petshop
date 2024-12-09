import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/PetProductModel.dart';  // Import model đại diện cho sản phẩm
import '../model/CartModel.dart';  // Import model đại diện cho sản phẩm
import '../constant/apilist.dart';

class CartRepository {
  final apiUrl = api_add_to_cart;  // API để thêm sản phẩm vào giỏ hàng

  // Phương thức để thêm sản phẩm vào giỏ hàng
  Future<String> addToCart({required String productId}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',  // Thêm token để xác thực người dùng
    };

    try {
      // Gửi yêu cầu POST với product_id
      final response = await http.post(
        Uri.parse(api_add_to_cart),
        headers: headers,
        body: jsonEncode({
          'product_id': productId,  // Truyền product_id vào body của yêu cầu
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
      return '200';
    } else if (response.statusCode == 400) {
      return '400'; // Xử lý lỗi theo API
    } else {
      return '500'; // Xử lý lỗi chung
    }
  } catch (e) {
    print('Exception occurred in addToCart: $e');
      throw Exception('Network error: $e'); // Ném exception nếu cần
    }
  }

  // Lấy danh sách thông báo
  Future<List<PetProduct>> getCartItems(int userId) async {
    final response = await http.get(Uri.parse('$api_get_cart/$userId'));
    
    if (response.statusCode == 200) {
      // Parse the response
      return (json.decode(response.body) as List)
          .map((data) => PetProduct.fromJson(data))
          .toList();
    } else {
      throw Exception('Failed to load cart items: ${response.body}');
    }
  }
}

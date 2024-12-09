import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/ProductOrderModel.dart'; // Đảm bảo bạn đã tạo model cho Order
import '../constant/apilist.dart';

class ProductOrderRepository {
  final apiUrl = api_product_order; // Địa chỉ API cho đơn hàng

  Future<http.Response> createproductOrder({
    required String addressId,
    required List<Map<String, dynamic>> products,
    required double shippingCost,
    required double tax,
  }) async {
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token', // Đảm bảo bạn đã định nghĩa token
    };

    // Tính tổng giá trị đơn hàng
    double total = 0.0;
    for (var product in products) {
      total += product['price'] * product['quantity'];
    }
    total += shippingCost + tax;

    // Tạo body cho yêu cầu
    final body = jsonEncode({
      'address_id': addressId,
      'products': products,
      'shipping_cost': shippingCost,
      'tax': tax,
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: body,
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        return response;
      } else {
        print('Error response: ${response.body}');
        throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to create order');
      }
    } on Exception catch (e) {
      print('Exception occurred: $e');
      throw Exception('Network error occurred: $e');
    }
  }

  // Hàm lấy thông tin sản phẩm đã đặt
  Future<List<ProductOrderModel>> fetchOrderedProducts() async {
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.get(
        Uri.parse(api_get_product_order),
        headers: headers,
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        if (response.headers['content-type']?.contains('application/json') == true) {
          final data = jsonDecode(response.body);
          
          // More robust null checking for 'orders'
          if (data != null && data['orders'] != null && data['orders'] is List) {
            return (data['orders'] as List)
                .map((order) => ProductOrderModel.fromJson(order))
                .toList();
          } else {
            print('No orders found or invalid format');
            return []; 
          }
        } else {
          print('Invalid response format: ${response.headers['content-type']}');
          throw Exception('Invalid response format: Expected JSON');
        }
      } else {
        // More robust error message handling
        final errorMessage = response.body != null 
            ? (jsonDecode(response.body)['message'] ?? 'Failed to retrieve orders')
            : 'Failed to retrieve orders';
        print('Error response: ${response.body}');
        throw Exception(errorMessage);
      }
    } on FormatException catch (e) {
      print('FormatException occurred: $e');
      throw Exception('Invalid JSON format: $e');
    } on Exception catch (e) {
      print('Exception occurred: $e');
      throw Exception('Network error occurred: $e');
    }
  }

}

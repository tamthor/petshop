import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/OrderModel.dart'; // Đảm bảo bạn đã tạo model cho Order
import '../constant/apilist.dart';

class OrderRepository {
  final apiUrl = api_order; // Địa chỉ API cho đơn hàng

  Future<http.Response> createOrder({
    required String addressId,
    required String petId,
    required double petPrice,
    required int quantity,
    required double shippingCost,
    required double tax,
  }) async {
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token', // Đảm bảo bạn đã định nghĩa token
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode({
          'address_id': addressId,
          'pet_id': petId,
          'pet_price': petPrice,
          'quantity': quantity,
          'shipping_cost': shippingCost,
          'tax': tax,
        }),
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

  Future<List<OrderModel>> getUserOrders(String userId) async {
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token', // Đảm bảo bạn đã định nghĩa token
    };

    try {
      final response = await http.get(
        Uri.parse('$apiUrl/user/$userId'), // Địa chỉ API để lấy đơn hàng của người dùng
        headers: headers,
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        if (response.headers['content-type']?.contains('application/json') == true) {
          final data = jsonDecode(response.body)['orders'] as List;
          return data.map((order) => OrderModel.fromJson(order)).toList();
        } else {
          print('Invalid response format: ${response.headers['content-type']}');
          throw Exception('Invalid response format: Expected JSON');
        }
      } else {
        print('Error response: ${response.body}');
        throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to retrieve orders');
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

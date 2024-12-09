import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/AdressesModel.dart';
// import '../repository/auth_repository.dart';
import '../constant/apilist.dart';

class AddressRepository {
  final apiUrl = api_address;
  
  Future<AddressModel> createAddress({
    required String addressLine1,
    String? addressLine2,
    required String city,
    required String state,
    required String postalCode,
    String? phoneNumber,
    bool? isDefault,
  }) async {
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.post(
        Uri.parse(api_address),
        headers: headers,
        body: jsonEncode({
          'address_line1': addressLine1,
          'address_line2': addressLine2,
          'city': city,
          'state': state,
          'postal_code': postalCode,
          'phone_number': phoneNumber,
          'is_default': isDefault,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        return AddressModel.fromJson(jsonDecode(response.body)['data']);
      } else {
        print('Error response: ${response.body}');
        throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to create address');
      }
    } on Exception catch (e) {
      print('Exception occurred: $e');
      throw Exception('Network error occurred: $e');
    }
  }

  Future<List<AddressModel>> getUserAddresses(String userId) async {
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.get(
        Uri.parse('$apiUrl/$userId'),
        headers: headers,
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        if (response.headers['content-type']?.contains('application/json') == true) {
          final data = jsonDecode(response.body)['data'] as List;
          return data.map((address) => AddressModel.fromJson(address)).toList();
        } else {
          print('Invalid response format: ${response.headers['content-type']}');
          throw Exception('Invalid response format: Expected JSON');
        }
      } else {
        print('Error response: ${response.body}');
        throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to retrieve addresses');
      }
    } on FormatException catch (e) {
      print('FormatException occurred: $e');
      throw Exception('Invalid JSON format: $e');
    } on Exception catch (e) {
      print('Exception occurred: $e');
      throw Exception('Network error occurred: $e');
    }
  }

  Future<AddressModel> updateAddress({
    required String id,
    required String addressLine1,
    String? addressLine2,
    required String city,
    required String state,
    required String postalCode,
    String? phoneNumber,
    bool? isDefault,
  }) async {
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.put(
        Uri.parse('$apiUrl/$id'),
        headers: headers,
        body: jsonEncode({
          'address_line1': addressLine1,
          'address_line2': addressLine2,
          'city': city,
          'state': state,
          'postal_code': postalCode,
          'phone_number': phoneNumber,
          'is_default': isDefault,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return AddressModel.fromJson(jsonDecode(response.body)['data']);
      } else {
        print('Error response: ${response.body}');
        throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to update address');
      }
    } on Exception catch (e) {
      print('Exception occurred: $e');
      throw Exception('Network error occurred: $e');
    }
  }

  Future<void> deleteAddress(String id) async {
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.delete(
        Uri.parse('$apiUrl/$id'),
        headers: headers,
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode != 200) {
        print('Error response: ${response.body}');
        throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to delete address');
      }
    } on Exception catch (e) {
      print('Exception occurred: $e');
      throw Exception('Network error occurred: $e');
    }
  }
} 
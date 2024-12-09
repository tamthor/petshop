import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constant/apilist.dart';
import '../model/PetProductModel.dart';
import '../model/pet_category.dart';
import '../constant/app_constants.dart';

class PetProductRepository {
  final String apiUrl = api_product;


  Future<List<PetProduct>> fetchPetProducts() async {
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ' + token,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        if (responseData['success'] == true) {
          List<dynamic> petProductdata = responseData['data'];
          return petProductdata.map((json) {
            if (json['photo'] != null) {
              if (!json['photo'].startsWith('http')) {
                json['photo'] = '$IMAGE_BASE_URL${json['photo']}';
              }
            } else {
              // json['image'] = '$base/storage/photos/1731689098_1000032977.jpg';
            }
            return PetProduct.fromJson(json);
          }).toList();
        } else {
          throw Exception('API returned success: false');
        }
      } else {
        throw Exception('Failed to load pet products');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to load pet products');
    }
  }

  Future<List<PetCategory>> fetchProductCategories() async {
    try {
      final response = await http.get(
        Uri.parse(api_product_cat),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ' + token,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        if (responseData['success'] == true) {
          List<dynamic> categoriesData = responseData['data'];
          return categoriesData.map((json) => PetCategory.fromJson(json)).toList();
        } else {
          throw Exception('API returned success: false');
        }
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to load categories');
    }
  }

  Future<PetProduct> fetchPetProductDetail(String id) async {
    try {
      print('Calling API: $api_product_details/$id');
      
      final response = await http.get(
        Uri.parse('$api_product_details/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          var petproductData = responseData['data'];
          
          if (petproductData['photo'] != null && !petproductData['photo'].startsWith('http')) {
            petproductData['photo'] = '$IMAGE_BASE_URL${petproductData['photo']}';
          }
          
          return PetProduct.fromJson(petproductData);
        } else {
          throw Exception(responseData['message'] ?? 'API returned success: false');
        }
      } else {
        throw Exception('Failed to load pet detail: Status ${response.statusCode}');
      }
    } catch (e) {
      print('Error in fetchPetDetail: $e');
      rethrow;
    }
  }
}

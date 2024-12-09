import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constant/apilist.dart';
// import '../model/product.dart';
import '../model/pet.dart';
import '../model/pet_category.dart';
import '../constant/app_constants.dart';

class PetRepository {
  final String apiUrl = api_pets;


  Future<List<Pet>> fetchPets() async {
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
          List<dynamic> petsData = responseData['data'];
          return petsData.map((json) {
            if (json['image'] != null) {
              if (!json['image'].startsWith('http')) {
                json['image'] = '$IMAGE_BASE_URL${json['image']}';
              }
            } else {
              // json['image'] = '$base/storage/photos/1731689098_1000032977.jpg';
            }
            return Pet.fromJson(json);
          }).toList();
        } else {
          throw Exception('API returned success: false');
        }
      } else {
        throw Exception('Failed to load pets');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to load pets');
    }
  }

  Future<List<PetCategory>> fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse(api_categories),
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

  Future<Pet> fetchPetDetail(String id) async {
    try {
      print('Calling API: $api_pet_detail/$id');
      
      final response = await http.get(
        Uri.parse('$api_pet_detail/$id'),
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
          var petData = responseData['data'];
          
          if (petData['image'] != null && !petData['image'].startsWith('http')) {
            petData['image'] = '$IMAGE_BASE_URL${petData['image']}';
          }
          
          return Pet.fromJson(petData);
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

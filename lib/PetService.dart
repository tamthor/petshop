// PetService.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constant/apilist.dart'; // Import file apilist
import '../model/pet.dart';

class PetService {
  Future<List<Pet>> fetchPetsByCategory(int categoryId) async {
    try {
      final response = await http.get(Uri.parse('$api_pets_by_category/$categoryId'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> data = jsonResponse['data'] ?? [];
        return data.map((json) => Pet.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load pets');
      }
    } catch (e) {
      throw Exception('Error fetching pets: $e');
    }
  }
}

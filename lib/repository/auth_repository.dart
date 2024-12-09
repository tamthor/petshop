import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constant/pref_data.dart';
import '../constant/apilist.dart';
import '../model/user.dart';
import '../model/profile.dart';
import 'package:dio/dio.dart';

class AuthRepository {
  final String apiUrl =  api_login; // URL của API

  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'enail': email, 'password': password}),
      );
      print('REPONSE CODE');
      // print(response.statusCode);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // print(response.body);
        // Giả sử API trá vẽ token trong response
        final g_Token = data['token']['token'];
        PrefData.setToken(g_Token);

        // print(token);

        final initialProfile = Profile(
          phone: data['user']['phone'],
          full_name: data['user']['full_name'],
          address: data['user']['address'],
          photo: data['user']['photo'],
          email: data['user']['email'],
          id: data['user']['id'], // Added the required 'id' parameter
          // username: data['user']['username'],
        );


        print(initialProfile);

        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<void> register(User user) async {
    print(apiUrl);
    print(user.toJson());
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()),
      // body: user.toJson(),
    );
    print('Response ');
    print(response.body);
    if (response.statusCode == 200) {
      // Đăng ký thành công
    } else {
      throw Exception("Failed to register");
    }
  }

  Future<Dio> getDioClient() async {
    final dio = Dio();
    // Add any necessary base configuration, headers, etc.
    return dio;
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../constant/apilist.dart';

import '../model/profile.dart';

// Định nghĩa trạng thái cho quá trình đăng nhập
enum LoginStatus { initial, loading, success, error }

// Provider để quản lý trạng thái đăng nhập
class LoginNotifier extends StateNotifier<LoginStatus> {
  LoginNotifier() : super(LoginStatus.initial);

  Future<void> login(String email, String password) async {
    state = LoginStatus.loading;
    final url = Uri.parse(api_login);

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      print('Response Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.containsKey('token') && data['token'].containsKey('token')) {
          token = data['token']['token'];
          initialProfile = Profile(
            phone: data['user']['phone'],
            full_name: data['user']['full_name'],
            address: data['user']['address'],
            photo: data['user']['photo'],
            // username: data['user']['username'],
            email: data['user']['email'],
            id: data['user']['id'],
          );
          state = LoginStatus.success;
        } else {
          state = LoginStatus.error;
        }
      } else {
        state = LoginStatus.error;
      }
    } catch (error) {
      print('Error: $error');
      state = LoginStatus.error;
    }
  }
}

// Khởi tạo provider cho việc đăng nhập
final loginProvider = StateNotifierProvider<LoginNotifier, LoginStatus>((ref) {
  return LoginNotifier();
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../constant/apilist.dart';

// Định nghĩa trạng thái cho quá trình đăng ký
enum RegistrationStatus { initial, loading, success, error }

// Provider để quản lý trạng thái đăng ký
class RegistrationNotifier extends StateNotifier<RegistrationStatus> {
  RegistrationNotifier() : super(RegistrationStatus.initial);

  Future<void> register(String email, String password, String fullName, String phone, String address, String description) async {
    state = RegistrationStatus.loading;
    final url = Uri.parse(api_register);

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'full_name': fullName,
          'phone': phone,
          'address': address,
          'description': description,
        }),
      );
      print('Response Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        state = RegistrationStatus.success;
      } else {
        state = RegistrationStatus.error;
      }
    } catch (error) {
      print('Error: $error');
      state = RegistrationStatus.error;
    }
  }
}

// Khởi tạo provider cho việc đăng ký
final registrationProvider = StateNotifierProvider<RegistrationNotifier, RegistrationStatus>((ref) {
  return RegistrationNotifier();
}); 
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../model/NotificationModel.dart';
import '../constant/apilist.dart';

class NotificationRepository {
  final apiUrl = api_address;

  // Tạo thông báo
  Future<NotificationModel?> createNotification(NotificationModel notification) async {
    final response = await http.post(
      Uri.parse('$api_notification'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
        },
      body: json.encode(notification.toJson()),
    );

    if (response.statusCode == 201) {
      return NotificationModel.fromJson(json.decode(response.body)['notification']);
    } else {
      throw Exception('Failed to create notification');
    }
  }

  // Lấy danh sách thông báo
  Future<List<NotificationModel>> getNotifications(int userId) async {
    
    final response = await http.get(Uri.parse('$api_get_notification/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',}
        );
    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");
    print ('$api_get_notification/$userId');
    if (response.statusCode == 201) {
      List<dynamic> jsonResponse = json.decode(response.body)['notifications'];
      return jsonResponse.map((json) => NotificationModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load notifications');
    }
  }
}

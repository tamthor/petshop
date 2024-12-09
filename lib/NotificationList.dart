import 'package:flutter/material.dart';
import 'package:flutter_pet_shop/utils/Constant.dart';
// import 'package:flutter_pet_shop/utils/CustomWidget.dart';
// import 'package:flutter_pet_shop/utils/SizeConfig.dart';
import 'package:flutter_pet_shop/repository/notification_reponsitory.dart'; // Import NotificationRepository
import 'package:flutter_pet_shop/model/NotificationModel.dart'; // Import NotificationModel
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Ensure this import is present
import '../providers/profile_provider.dart'; // Import ProfileProvider

class NotificationList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileProvider); // Use watch to get profile state
    int userId = profileState.profile.id; // Get userId from profile

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text("Notifications"),
        backgroundColor: primaryColor,
      ),
      body: _NotificationListBody(userId: userId),
    );
  }
}

class _NotificationListBody extends StatefulWidget {
  final int userId;

  _NotificationListBody({required this.userId});

  @override
  _NotificationListBodyState createState() => _NotificationListBodyState();
}

class _NotificationListBodyState extends State<_NotificationListBody> {
  List<NotificationModel> _notificationList = [];
  bool isLoading = true; // To track loading state
  final NotificationRepository notificationRepository = NotificationRepository(); // Create instance of NotificationRepository

  @override
  void initState() {
    super.initState();
    fetchNotifications(); // Fetch notifications when the widget is initialized
  }

  Future<void> fetchNotifications() async {
    try {
      List<NotificationModel> notifications = await notificationRepository.getNotifications(widget.userId);
      setState(() {
        _notificationList = notifications;
        isLoading = false; // Set loading to false after fetching
      });
    } catch (e) {
      print("Error fetching notifications: $e");
      setState(() {
        isLoading = false; // Set loading to false even if there's an error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return isLoading
        ? Center(child: CircularProgressIndicator()) // Show loading indicator while fetching
        : _notificationList.isEmpty
            ? Center(child: Text("No notifications available.")) // Show message if no notifications
            : ListView.builder(
                itemCount: _notificationList.length,
                itemBuilder: (context, index) {
                  NotificationModel notification = _notificationList[index];
                  return Card(
                    elevation: 4, // Thêm bóng đổ cho Card
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16), // Khoảng cách giữa các Card
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // Bo tròn các góc
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16), // Padding cho nội dung
                      title: Text(
                        notification.title ?? "No Title",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Text(
                        notification.description ?? "No Description",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      trailing: Icon(Icons.notifications, color: primaryColor), // Biểu tượng thông báo
                      onTap: () {
                        // Xử lý khi người dùng nhấn vào thông báo
                      },
                    ),
                  );
                },
              );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_pet_shop/MainPage.dart';
import 'package:flutter_pet_shop/utils/Constant.dart';
import 'package:flutter_pet_shop/utils/CustomWidget.dart';
import 'model/AdressesModel.dart'; 
import 'model/pet.dart'; // Import model Pet
import 'customView/ReviewSlider.dart';
import 'providers/profile_provider.dart';
import 'repository/order_repository.dart'; // Import OrderRepository
import 'model/NotificationModel.dart'; // Import OrderModel
// Ensure you have this import
import 'repository/notification_reponsitory.dart'; // Nhập khẩu NotificationRepository
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Ensure this import is present

class ConfirmationPage extends StatefulWidget {
  final AddressModel selectedAddress; // Thêm tham số này
  final Pet pet; // Thêm tham số này

  const ConfirmationPage({Key? key, required this.selectedAddress, required this.pet}) : super(key: key);

  @override
  _ConfirmationPage createState() {
    return _ConfirmationPage();
  }
}

class _ConfirmationPage extends State<ConfirmationPage> {
  final double shippingCost = 5.0; // Ví dụ: tiền ship
  final double taxRate = 0.1; // Ví dụ: thuế 10%
  final OrderRepository orderRepository = OrderRepository(); // Tạo instance của OrderRepository
  final NotificationRepository notificationRepository = NotificationRepository(); // Tạo instance của NotificationRepository

  double calculateTotal() {
    double petPrice = widget.pet.price;
    double tax = petPrice * taxRate;
    return petPrice + shippingCost + tax;
  }

  // Phương thức để hiển thị modal đặt hàng thành công
  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 10),
              Text("Đặt hàng thành công!", style: TextStyle(color: Colors.green)),
            ],
          ),
          content: Text("Đơn hàng của bạn đã được xác nhận.", style: TextStyle(fontSize: 16)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop({
                  'success': true,
                  'petName': widget.pet.name,
                  'petPrice': widget.pet.price,
                });
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => MainPage()));
              },
              child: Text("OK", style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );
  }

  // Cập nhật phương thức _confirmOrder
  Future<void> _confirmOrder(String userId) async {
    double total = calculateTotal();

    try {
    final response = await orderRepository.createOrder(
      addressId: widget.selectedAddress.id.toString(),
      petId: widget.pet.id.toString(),
      petPrice: widget.pet.price,
      quantity: 1,
      shippingCost: shippingCost,
      tax: widget.pet.price * taxRate,
    );

    if (response.statusCode == 201) {
      // Tạo thông báo
      await notificationRepository.createNotification(NotificationModel(
        title: 'Order Confirmed',
        description: 'Your order for ${widget.pet.name} has been confirmed!',
        userId: int.tryParse(userId), // Convert userId to int
      ));

      // Truyền dữ liệu thông báo qua Navigator
      Navigator.of(context).pop({
        'title': 'Order Success',
        'desc': 'Your order for ${widget.pet.name} has been confirmed!',
      });

      // Hiển thị modal thông báo thành công
      // Đảm bảo rằng không có Navigator.pop() nào được gọi trước đó
      Future.delayed(Duration.zero, () {
        _showSuccessDialog(context);
      });
    } else {
      print("Order creation failed with status: ${response.statusCode}");
    }
  } catch (e) {
    print("Error: $e");
  }
  }

  // Thêm phương thức để hiển thị chi tiết tổng tiền
  Widget _buildTotalCostDetails() {
    double petPrice = widget.pet.price;
    double tax = petPrice * taxRate;
    double total = petPrice + shippingCost + tax;

    return Container(
      margin: EdgeInsets.symmetric(vertical: getScreenPercentSize(context, 2)),
      padding: EdgeInsets.all(getScreenPercentSize(context, 2)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCostRow("Pet Price", petPrice),
          _buildCostRow("Shipping Cost", shippingCost),
          _buildCostRow("Tax", tax),
          Divider(color: Colors.grey),
          _buildCostRow("Total", total, isTotal: true),
        ],
      ),
    );
  }

  // Phương thức để tạo một hàng hiển thị chi phí
  Widget _buildCostRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: getScreenPercentSize(context, 0.5)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.black : Colors.grey[700],
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.black : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
        builder: (context, ref, child) {
            // Get the user ID from the profile provider
            final userId = ref.read(profileProvider).profile.id; // Lấy user_id từ ProfileProvider

            return WillPopScope(
                child: Scaffold(
                    backgroundColor: backgroundColor,
                    appBar: AppBar(
                        elevation: 0,
                        centerTitle: true,
                        toolbarHeight: 0,
                        backgroundColor: backgroundColor,
                        title: getAppBarText(context, 'Confirmation'),
                        leading: Builder(
                            builder: (BuildContext context) {
                                return IconButton(
                                    icon: getAppBarIcon(),
                                    onPressed: () {
                                        Navigator.of(context).pop();
                                    },
                                );
                            },
                        ),
                    ),
                    body: Padding(
                        padding: EdgeInsets.symmetric(horizontal: getScreenPercentSize(context, 2)),
                        child: Column(
                            children: [
                                getAppBar(context, "Confirmation", isBack: true, function: () {
                                    Navigator.of(context).pop();
                                }),
                                SizedBox(height: getScreenPercentSize(context, 1.5),),

                                // Thêm ReviewSlider
                                ReviewSlider(
                                    optionStyle: TextStyle(
                                        fontFamily: customFontFamily,
                                        fontSize: getScreenPercentSize(context, 1.7),
                                        color: textColor,
                                        fontWeight: FontWeight.w500,
                                    ),
                                    onChange: (index) {},
                                    initialValue: 1,
                                    circleDiameter: getScreenPercentSize(context, 5.5),
                                    isCash: false,
                                    width: double.infinity,
                                    options: getOption(),
                                ),

                                SizedBox(height: getScreenPercentSize(context, 2)),

                                // Hiển thị địa chỉ đã chọn
                                getMaterialCell(context, widget: Container(
                                    width: double.infinity,
                                    margin: EdgeInsets.only(bottom: getScreenPercentSize(context, 2)),
                                    padding: EdgeInsets.all(getScreenPercentSize(context, 2)),
                                    decoration: getDecorationWithRadius(getScreenPercentSize(context, 1.5), primaryColor),
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                            getCustomTextWithoutAlignWithFontFamily(
                                                'Shipping Address',
                                                textColor,
                                                FontWeight.w500,
                                                getScreenPercentSize(context, 1.8),
                                            ),
                                            SizedBox(height: getScreenPercentSize(context, 1)),
                                            getCustomTextWithoutAlign(
                                                '${widget.selectedAddress.addressLine1}, ${widget.selectedAddress.city}, ${widget.selectedAddress.state}',
                                                textColor,
                                                FontWeight.w400,
                                                getScreenPercentSize(context, 1.8),
                                            ),
                                        ],
                                    ),
                                )),

                                // Hiển thị thông tin sản phẩm
                                Container(
                                    margin: EdgeInsets.only(bottom: getScreenPercentSize(context, 2)),
                                    child: Column(
                                        children: [
                                            // Tạo một widget cho từng sản phẩm
                                            _buildProductCard(widget.pet),
                                        ],
                                    ),
                                ),

                                // Hiển thị chi tiết tổng tiền
                                _buildTotalCostDetails(), // Gọi widget hiển thị chi tiết tổng tiền
                                Spacer(),
                                Container(
                                    margin: EdgeInsets.only(top: getScreenPercentSize(context, 0.5)),
                                    child: getButtonWidget(context, "Confirm", primaryColor, () async {
                                        await _confirmOrder(userId.toString()); // Gọi phương thức xác nhận đơn hàng
                                    }),
                                ),

                                // Các phần khác của ConfirmationPage...
                            ],
                        ),
                    ),
                ),
                onWillPop: () async {
                    Navigator.of(context).pop();
                    return true;
                },
            );
        },
    );
  }

  // Định nghĩa ThankYouDialog
  Widget ThankYouDialog(BuildContext context) {
    return AlertDialog(
      title: Text("Cảm ơn bạn!"),
      content: Text("Đơn hàng của bạn đã được xác nhận."),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Đóng dialog
          },
          child: Text("OK"),
        ),
      ],
    );
  }

  // Widget để hiển thị thông tin sản phẩm
  Widget _buildProductCard(Pet pet) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: getScreenPercentSize(context, 1)),
      padding: EdgeInsets.all(getScreenPercentSize(context, 2)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Hình ảnh sản phẩm
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              pet.image,
              width: getScreenPercentSize(context, 10), // Giảm chiều rộng hình ảnh
              height: getScreenPercentSize(context, 10), // Giảm chiều cao hình ảnh
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: getScreenPercentSize(context, 2)),
          // Thông tin sản phẩm
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pet.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: getScreenPercentSize(context, 0.5)),
                Text(
                  'Original Chose',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: getScreenPercentSize(context, 0.5)),
                Text(
                  '\$${pet.price}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.purple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Nút xóa sản phẩm (nếu cần)
          IconButton(
            icon: Icon(Icons.pets, color: const Color.fromARGB(255, 119, 81, 184)),
            onPressed: () {
              // Xử lý xóa sản phẩm
            },
          ),
        ],
      ),
    );
  }

  List<String> getOption() {
    return [
      'Address',
      'Payment',
      'Confirmation',
    ];
  }
}

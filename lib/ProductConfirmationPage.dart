import 'package:flutter/material.dart';
import 'package:flutter_pet_shop/MainPage.dart';
import 'package:flutter_pet_shop/utils/Constant.dart';
import 'package:flutter_pet_shop/utils/CustomWidget.dart';
// import 'package:flutter_pet_shop/utils/SizeConfig.dart';
import 'model/AdressesModel.dart'; 
import 'model/PetProductModel.dart'; // Import model Pet
import 'customView/ReviewSlider.dart';
import 'repository/notification_reponsitory.dart'; // Nhập khẩu NotificationRepository
import 'providers/profile_provider.dart';
import 'repository/productorder_reponsitory.dart'; // Import OrderRepository
import 'model/NotificationModel.dart'; // Import NotificationModel
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Ensure this import is present

class ProductConfirmationPage extends StatefulWidget {
  final AddressModel selectedAddress; // Thêm tham số này
  final List<PetProduct> petProducts; // Thêm tham số này

  const ProductConfirmationPage({Key? key, required this.selectedAddress, required this.petProducts}) : super(key: key);

  @override
  _ProductConfirmationPage createState() {
    return _ProductConfirmationPage();
  }
}

class _ProductConfirmationPage extends State<ProductConfirmationPage> {
  final double shippingCost = 5.0; // Ví dụ: tiền ship
  final double taxRate = 0.1; // Ví dụ: thuế 10%
  final ProductOrderRepository orderRepository = ProductOrderRepository(); // Tạo instance của OrderRepository
  final NotificationRepository notificationRepository = NotificationRepository(); // Tạo instance của NotificationRepository

  // Thay đổi biến quantity thành một danh sách
  late List<int> quantities; // Đánh dấu là 'late' để trì hoãn khởi tạo

  @override
  void initState() {
    super.initState();
    // Khởi tạo danh sách quantities với số lượng mặc định cho mỗi sản phẩm
    quantities = List<int>.filled(widget.petProducts.length, 1);
  }

  double calculateTotal() {
    double totalProductPrice = 0.0;

    // Tính tổng giá cho tất cả các sản phẩm
    for (var product in widget.petProducts) {
        totalProductPrice += product.price.toDouble() * quantities[widget.petProducts.indexOf(product)]; // Nhân với số lượng
    }

    double tax = totalProductPrice * taxRate; // Tính thuế
    return totalProductPrice + shippingCost + tax; // Trả về tổng cộng
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
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => MainPage()),
                  (Route<dynamic> route) => false,
                );
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
      final response = await orderRepository.createproductOrder(
        addressId: widget.selectedAddress.id.toString(),
        products: widget.petProducts.map((product) => {
          'id': product.id,
          'price': product.price,
          'quantity': quantities[widget.petProducts.indexOf(product)],
        }).toList(),
        shippingCost: shippingCost,
        tax: widget.petProducts[0].price * taxRate,
      );

      if (response.statusCode == 201) {
        // Tạo thông báo
        await notificationRepository.createNotification(NotificationModel(
          title: 'Order Confirmed',
          description: 'Your order for ${widget.petProducts[0].title} has been confirmed!',
          userId: int.tryParse(userId), // Convert userId to int
        ));

        // Hiển thị modal thông báo thành công
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
            body: ListView(
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

                // Hiển thị thông tin sản phẩm
                Column(
                  children: widget.petProducts.asMap().entries.map((entry) {
                    int index = entry.key;
                    PetProduct petProduct = entry.value;
                    return _buildProductCard(petProduct, index); // Truyền index vào hàm
                  }).toList(),
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

                // Các phần khác của ProductConfirmationPage...
              ],
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

  // Cập nhật phương thức _buildProductCard để nhận index
  Widget _buildProductCard(PetProduct petProduct, int index) {
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
              petProduct.photo,
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
                  petProduct.title,
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
                  '${petProduct.price} vnđ',
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
          // Thay đổi phần quantity selector
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.remove, color: Colors.redAccent),
                  onPressed: () {
                    setState(() {
                      if (quantities[index] > 1) quantities[index]--; // Giảm số lượng cho sản phẩm hiện tại
                    });
                  },
                ),
                Text(
                  quantities[index].toString(), // Hiển thị số lượng cho sản phẩm hiện tại
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.add, color: Colors.green),
                  onPressed: () {
                    setState(() {
                      quantities[index]++; // Tăng số lượng cho sản phẩm hiện tại
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Thêm phương thức để hiển thị chi tiết tổng tiền
  Widget _buildTotalCostDetails() {
    double totalProductPrice = 0.0;

    // Tính tổng giá cho tất cả các sản phẩm
    for (var product in widget.petProducts) {
        totalProductPrice += product.price.toDouble() * quantities[widget.petProducts.indexOf(product)]; // Nhân với số lượng
    }

    double tax = totalProductPrice * taxRate; // Tính thuế
    double total = totalProductPrice + shippingCost + tax; // Tính tổng

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
                _buildCostRow("Product Price", totalProductPrice), // Hiển thị tổng giá sản phẩm
                _buildCostRow("Shipping Cost", shippingCost),
                _buildCostRow("Tax", tax),
                Divider(color: Colors.grey),
                _buildCostRow("Total", total, isTotal: true), // Hiển thị tổng cộng
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
            '${amount.toStringAsFixed(2)} vnđ',
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

  List<String> getOption() {
    return [
      'Address',
      'Payment',
      'Confirmation',
    ];
  }
}

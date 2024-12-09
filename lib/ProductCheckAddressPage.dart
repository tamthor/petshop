import 'package:flutter/material.dart';
import 'package:flutter_pet_shop/ProductCheckoutPage.dart';
import 'package:flutter_pet_shop/EditAddressPage.dart';
import 'package:flutter_pet_shop/utils/Constant.dart';
import 'package:flutter_pet_shop/utils/CustomWidget.dart';
import 'package:flutter_pet_shop/utils/SizeConfig.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/profile_provider.dart';
import 'AddNewAddressPage.dart';
import 'customView/ReviewSlider.dart';
import 'model/AdressesModel.dart';
import 'repository/address_repository.dart';
import 'model/PetProductModel.dart'; // Import model Pet

class ProductCheckAddressPage extends ConsumerStatefulWidget {
  final List<PetProduct> petProducts; // Thay đổi từ PetProduct sang List<PetProduct>

  const ProductCheckAddressPage({Key? key, required this.petProducts}) : super(key: key);

  @override
  _ProductCheckAddressPage createState() => _ProductCheckAddressPage();
}

class _ProductCheckAddressPage extends ConsumerState<ProductCheckAddressPage> {
  List<AddressModel> addressList = [];
  final AddressRepository addressRepository = AddressRepository();
  String? userId; // Để null ban đầu
  bool hasFetchedAddresses = false; // Cờ để kiểm tra địa chỉ đã tải chưa
  int? selectedAddressIndex; // Add this variable to track the selected address

  @override
  void initState() {
    super.initState();
    fetchUserAddresses(); // Gọi hàm tải địa chỉ ngay khi khởi tạo
  }

  Future<void> fetchUserAddresses() async {
    if (userId == null || hasFetchedAddresses) {
      print('User ID is null or addresses have already been fetched.');
      return;
    }
    try {
      print('Fetching addresses for user ID: $userId');
      addressList = await addressRepository.getUserAddresses(userId!);
      hasFetchedAddresses = true; // Đặt cờ đã tải địa chỉ
      print('Fetched addresses: $addressList');
      setState(() {}); // Cập nhật giao diện
    } catch (e) {
      print('Error fetching addresses: $e');
    }
  }

  Future<bool> _requestPop() async {
    await fetchUserAddresses(); // Tải lại danh sách địa chỉ khi quay lại
    return true; // Return true to allow the pop
  }

  List<String> getOption() {
    return [
      'Address',
      'Payment',
      'Confirmation',
      // Add more options as needed
    ];
  }

  void _showAlertDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(Icons.info, color: primaryColor),
              SizedBox(width: 10),
              Text(title, style: TextStyle(color: primaryColor)),
            ],
          ),
          content: Text(content, style: TextStyle(fontSize: 16)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK", style: TextStyle(color: primaryColor)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider); // Theo dõi profileProvider

    // Cập nhật userId và gọi fetchUserAddresses nếu cần
    if (profileState.profile.id.toString() != userId) {
      userId = profileState.profile.id.toString();
      hasFetchedAddresses = false; // Reset cờ để tải địa chỉ mới
      fetchUserAddresses(); // Gọi hàm tải địa chỉ
    }

    SizeConfig().init(context);
    double leftMargin = getHorizontalSpace(context);
    double topMargin = getScreenPercentSize(context, 1);
    double cellHeight = MediaQuery.of(context).size.width * 0.2;

    return WillPopScope(
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          toolbarHeight: 0,
          backgroundColor: backgroundColor,
          title: getAppBarText(context, 'Checkout'),
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: getAppBarIcon(),
                onPressed: _requestPop,
              );
            },
          ),
        ),
        body: Container(
          child: Column(
            children: [
              getAppBar(context, "Checkout", isBack: true, function: () {
                _requestPop();
              }),
              SizedBox(height: getScreenPercentSize(context, 1.5)),
              ReviewSlider(
                optionStyle: TextStyle(
                  fontFamily: customFontFamily,
                  fontSize: getScreenPercentSize(context, 1.7),
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
                onChange: (index) {},
                initialValue: 0,
                circleDiameter: getScreenPercentSize(context, 5.5),
                isCash: false,
                width: double.infinity,
                options: getOption(),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    margin: EdgeInsets.only(top: leftMargin),
                    padding: EdgeInsets.only(left: leftMargin, right: leftMargin),
                    child: Column(
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: addressList.length,
                          itemBuilder: (context, index) {
                            return InkWell(
                              child: getMaterialCell(
                                context,
                                widget: Container(
                                  margin: EdgeInsets.only(bottom: getWidthPercentSize(context, 3)),
                                  padding: EdgeInsets.all(getPercentSize(cellHeight, 10)),
                                  decoration: getDecorationWithRadius(getPercentSize(cellHeight, 10), primaryColor),
                                  height: cellHeight,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        children: [
                                          Radio<int>(
                                            value: index, // Set the value to the index
                                            groupValue: selectedAddressIndex, // Bind to the selected address index
                                            onChanged: (int? value) {
                                              setState(() {
                                                selectedAddressIndex = value; // Update the selected address index
                                              });
                                            },
                                          ),
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    SizedBox(width: getWidthPercentSize(context, 2)),
                                                    Expanded(
                                                      child: getCustomTextWithoutAlignWithFontFamily(
                                                        addressList[index].phoneNumber ?? 'No PhoneNumber',
                                                        textColor,
                                                        FontWeight.w500,
                                                        getPercentSize(cellHeight, 20),
                                                      ),
                                                      flex: 1,
                                                    ),
                                                  ],
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                    top: (topMargin / 2),
                                                    left: (getWidthPercentSize(context, 2) + getPercentSize(cellHeight, 25)),
                                                  ),
                                                  child: getCustomTextWidget(
                                                    '${addressList[index].addressLine1}, ${addressList[index].city}, ${addressList[index].state}'.length > 50 
                                                      ? '${addressList[index].addressLine1}, ${addressList[index].city}, ${addressList[index].state}'.substring(0, 50) + '...' 
                                                      : '${addressList[index].addressLine1}, ${addressList[index].city}, ${addressList[index].state}',
                                                    textColor,
                                                    getPercentSize(cellHeight, 15),
                                                    FontWeight.w400,
                                                    TextAlign.start,
                                                    2,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: Row(
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.only(right: 3),
                                                  child: InkWell(
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(builder: (context) => EditAddressPage()),
                                                      );
                                                    },
                                                    child: Image.asset(
                                                      assetsPath + "edit.png",
                                                      height: getPercentSize(cellHeight, 20),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(right: 3),
                                                  child: InkWell(
                                                    onTap: () async {
                                                      try {
                                                        await addressRepository.deleteAddress(addressList[index].id.toString());
                                                        setState(() {
                                                          addressList.removeAt(index); // Xóa địa chỉ khỏi danh sách
                                                        });
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          SnackBar(content: Text('Address deleted successfully')),
                                                        );
                                                      } catch (e) {
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          SnackBar(content: Text('Failed to delete address')),
                                                        );
                                                      }
                                                    },
                                                    child: Icon(
                                                      Icons.delete,
                                                      color: Colors.red,
                                                      size: getPercentSize(cellHeight, 20),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              onTap: () {
                                // Xử lý khi nhấn vào địa chỉ
                              },
                            );
                          },
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: getScreenPercentSize(context, 0.5)),
                          child: getAddButtonWidget(
                            context,
                            "Add New Address",
                            primaryColor,
                            () async {
                              // Gọi fetchProfile trước khi điều hướng
                              await ref.read(profileProvider.notifier).fetchProfile();
                              final newAddress = await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => AddNewAddressPage()),
                              );

                              // Kiểm tra xem có địa chỉ mới không và cập nhật danh sách địa chỉ
                              if (newAddress != null) {
                                addressList.add(newAddress); // Thêm địa chỉ mới vào danh sách
                                setState(() {}); // Cập nhật giao diện
                              }
                            },
                          ),
                        ),
                        // Hiển thị thông tin sản phẩm
                      ],
                    ),
                  ),
                ),
                flex: 1,
              ),
              Container(
                margin: EdgeInsets.only(top: getScreenPercentSize(context, 0.5)),
                child: getButtonWidget(
                  context,
                  "Next",
                  primaryColor,
                  () {
                    if (selectedAddressIndex != null) {
                      // Pass the selected address to the CheckOutPage
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductCheckoutPage(
                            selectedAddress: addressList[selectedAddressIndex!], // Pass the selected address
                            petProducts: widget.petProducts, // Truyền đối tượng pet
                          ),
                        ),
                      );
                    } else {
                      // Show an alert if no address is selected
                      _showAlertDialog(context, "Thông báo", "Vui lòng chọn địa chỉ giao hàng.");
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      onWillPop: _requestPop,
    );
  }

  void processPayment(List<PetProduct> products) {
    // Thực hiện logic thanh toán cho tất cả sản phẩm
    // Ví dụ: Gọi API thanh toán với danh sách sản phẩm
    print("Processing payment for products: $products");
    // Thực hiện thanh toán và xử lý phản hồi
  }
}


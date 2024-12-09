import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pet_shop/MainPage.dart';
import 'package:flutter_pet_shop/ProductDetailPage.dart';
import 'package:flutter_pet_shop/model/PetProductModel.dart';
import 'package:flutter_pet_shop/utils/Constant.dart';
import 'package:flutter_pet_shop/utils/CustomWidget.dart';
import 'package:flutter_pet_shop/utils/PrefData.dart';
import 'package:flutter_pet_shop/utils/SizeConfig.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_pet_shop/constant/apilist.dart';
import 'package:flutter_pet_shop/constant/app_constants.dart';
import 'package:flutter_pet_shop/ProductCheckAddressPage.dart';

class AddToCartPage extends StatefulWidget {
  final Function? function;
  final List<PetProduct>? listItems;  // Changed from List<ProductModel> to List<Product>

  AddToCartPage({this.function, this.listItems});

  @override
  _AddToCartPage createState() => _AddToCartPage();
}

class _AddToCartPage extends State<AddToCartPage> {
  List<PetProduct> cartModelList = [];  // Changed from List<ProductModel> to List<Product>

  bool _isSignIn = false;
  bool isData = false;
  double leftMargin = 0;
  
  @override
  void initState() {
    super.initState();
    signInValue();
    fetchCartData().then((_) {
        isDataAvailable();  // Gọi isDataAvailable() sau khi fetchCartData() hoàn tất
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchCartData(); // Gọi lại fetchCartData khi trang được hiển thị
  }

  Future<void> fetchCartData() async {
    try {
      List<PetProduct> products = await getCart();
      print("List<Product>: " + products.toString());
      setState(() {
        cartModelList = products;  // Cập nhật cartModelList với dữ liệu mới
        isData = cartModelList.isNotEmpty;  // Cập nhật isData ngay sau khi cartModelList được cập nhật
      });
      print(cartModelList);
    } catch (e) {
      print("Error fetching cart data: $e");
    }
  }


  Future<List<PetProduct>> getCart() async {
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',  // Add token for authentication
    };
    try {
      final response = await http.get(Uri.parse(api_get_cart), headers: headers);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        if (responseData['success'] == true) {
          List<dynamic> petProductdata = responseData['data'];
          return petProductdata.map((json) {
            if (json['photo'] != null) {
              if (!json['photo'].startsWith('http')) {
                json['photo'] = '$IMAGE_BASE_URL${json['photo']}';
              }
            } else {
              // json['image'] = '$base/storage/photos/1731689098_1000032977.jpg';
            }
            return PetProduct.fromJson(json);
          }).toList();
        } else {
          throw Exception('API returned success: false');
        }
      } else {
        throw Exception('Failed to load pet products');
      }
    } catch (e) {
      print('Exception occurred: $e');
      return [];
    }
  }

  isDataAvailable() async {
    // isData = await PrefData.getIsCart();
    isData = cartModelList.isNotEmpty;
    print("Trạng thái Data: " + isData.toString());
    setState(() {});
  }

  Future<bool> _requestPop() {
    if (widget.function != null) {
      widget.function!();
    } else {
      Navigator.of(context).pop();
    }
    return Future.value(true);
  }

  void signInValue() async {
    _isSignIn = await PrefData.getIsSignIn();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    leftMargin = getHorizontalSpace(context);
    double height = getScreenPercentSize(context, 3);

    return WillPopScope(
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: backgroundColor,
          elevation: 0,
          toolbarHeight: 0,
        ),
        body: Container(
          child: Column(
            children: [
              getAppBar(context, "Cart", isBack: true, function: () {
                _requestPop();
              },widget: InkWell(
                onTap: () {
                  fetchCartData(); // Gọi lại fetchCartData khi nhấn nút reload
                },
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(Icons.refresh), // Biểu tượng reload
                      SizedBox(width: 8), // Khoảng cách giữa biểu tượng và văn bản
                    ],
                  ),
                ),
              )),
              SizedBox(height: getScreenPercentSize(context, 1.5)),
              Expanded(
                child: isData
                    ? Container(
                        margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.width * 0.01),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: cartModelList.length,
                          itemBuilder: (context, index) {
                            return ListItem(
                              index, 
                              cartModelList[index], 
                              () {
                                // Sau khi xóa sản phẩm, gọi lại fetchCartData để reload giỏ hàng
                                fetchCartData();
                              }
                            );
                          },
                        ),
                      )
                    : emptyWidget(),
                flex: 1,
              ),
              Visibility(
                visible: isData,
                child: Container(
                  padding: EdgeInsets.only(top: leftMargin),
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: leftMargin),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Chuyển đến ProductCheckAddressPage với tất cả sản phẩm trong giỏ hàng
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductCheckAddressPage(
                                petProducts: cartModelList, // Truyền danh sách sản phẩm
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor, // Màu nền
                          foregroundColor: Colors.white, // Màu chữ
                          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30), // Padding
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30), // Bo tròn góc
                          ),
                          elevation: 5, // Đổ bóng
                        ),
                        child: Text(
                          "Proceed to Checkout",
                          style: TextStyle(
                            fontSize: 18, // Kích thước chữ
                            fontWeight: FontWeight.bold, // Đậm
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      onWillPop: _requestPop,
    );
  }

  getRoWCell(String s, String s1) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: getCustomTextWidget(s, textColor, getScreenPercentSize(context, 2), FontWeight.w800, TextAlign.start, 1),
          flex: 1,
        ),
        Expanded(
          child: getCustomTextWidget(s1, subTextColor, getScreenPercentSize(context, 2), FontWeight.w500, TextAlign.end, 1),
          flex: 1,
        ),
      ],
    );
  }

  void removeItem(int index) {
    setState(() {
      // Remove the item from the list (you can implement actual removal logic here)
    });
  }

  emptyWidget() {
    double width = getWidthPercentSize(context, 45);
    double height = getScreenPercentSize(context, 7);
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(assetsPath + "cart_item.png", height: getScreenPercentSize(context, 20)),
          SizedBox(height: getScreenPercentSize(context, 3)),
          getCustomTextWithFontFamilyWidget("Your Cart is Empty Yet!", textColor, getScreenPercentSize(context, 2.5), FontWeight.w500, TextAlign.center, 1),
          SizedBox(height: getScreenPercentSize(context, 1)),
          getCustomTextWidget("Explore more and shortlist some pets.", textColor, getScreenPercentSize(context, 2), FontWeight.w400, TextAlign.center, 1),
          InkWell(
            onTap: () {
              PrefData.setIsCart(true);
              Navigator.push(context, MaterialPageRoute(builder: (context) => MainPage()));
            },
            child: getMaterialCell(
              context,
              widget: Container(
                margin: EdgeInsets.only(top: getScreenPercentSize(context, 4)),
                width: width,
                height: height,
                decoration: ShapeDecoration(
                  color: backgroundColor,
                  shape: SmoothRectangleBorder(
                    side: BorderSide(color: primaryColor, width: 1.5),
                    borderRadius: SmoothBorderRadius(
                      cornerRadius: getPercentSize(height, 25),
                      cornerSmoothing: 0.8,
                    ),
                  ),
                ),
                child: Center(
                  child: getCustomTextWidget("Go to Shop", primaryColor, getPercentSize(width, 10), FontWeight.w600, TextAlign.center, 1),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ListItem extends StatefulWidget {
  final PetProduct product;  // Changed from ProductModel to Product
  final int index;
  final Function? onChanged;

  ListItem(this.index, this.product, this.onChanged);

  @override
  _ListItemState createState() => _ListItemState(product, onChanged);
}

class _ListItemState extends State<ListItem> {
  final PetProduct product;  // Changed from ProductModel to Product
  final Function? onChanged;

  _ListItemState(this.product, this.onChanged);

  @override
  Widget build(BuildContext context) {
    double height = getScreenPercentSize(context, 12);
    double imageSize = getPercentSize(height, 90);
    double margin = getScreenPercentSize(context, 1.5);
    double radius = getScreenPercentSize(context, 1.5);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(productId: product.id),
          ),
        );
      },
      child: getMaterialCell(
        context,
        widget: Container(
          decoration: getDecoration(radius),
          margin: EdgeInsets.symmetric(vertical: getScreenPercentSize(context, 1), horizontal: getHorizontalSpace(context)),
          height: height,
          child: Row(
            children: [
              Container(
                height: imageSize,
                width: imageSize,
                margin: EdgeInsets.only(right: margin, left: getPercentSize(height, 5)),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusDirectional.circular(radius),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.network(
                    product.photo,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        getCustomTextWithFontFamilyWidget(
                          product.title,
                          textColor,
                          getPercentSize(height, 16),
                          FontWeight.w500,
                          TextAlign.start,
                          1,
                        ),
                        SizedBox(height: getPercentSize(height, 2)),
                        getCustomTextWidget(
                          product.summary ?? "",  // Use description if available
                          textColor,
                          getPercentSize(height, 12),
                          FontWeight.w400,
                          TextAlign.start,
                          1,
                        ),
                        SizedBox(height: getPercentSize(height, 10)),
                        Row(
                          children: [
                            Expanded(
                              child: getCustomTextWithFontFamilyWidget(
                                product.price.toString()!,
                                primaryColor,
                                getPercentSize(height, 15),
                                FontWeight.w400,
                                TextAlign.start,
                                1,
                              ),
                              flex: 1,
                            ),
                            // Padding(
                            //   padding: EdgeInsets.only(right: margin),
                            //   child: Row(
                            //     mainAxisAlignment: MainAxisAlignment.center,
                            //     children: [
                            //       getCartButton(Icons.remove, cellColor, textColor, () {
                            //         setState(() {
                            //         });
                            //       }),
                            //       Padding(
                            //         padding: EdgeInsets.symmetric(horizontal: getWidthPercentSize(context, 2)),
                            //         child: Center(
                            //         ),
                            //       ),
                            //       getCartButton(Icons.add, primaryColor, Colors.white, () {
                            //         // setState(() {
                            //         //   product.quantity++;
                            //         // });
                            //       }),
                            //     ],
                            //   ),
                            // ),
                          ],
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: () async {
                          // Call removeFromCart function here
                          bool success = await removeFromCart(int.parse(product.id));
                          if (success) {
                            // Successfully removed, update the cart list
                            if (onChanged != null) {
                              onChanged!();  // Gọi lại callback để reload giỏ hàng
                            }
                          } else {
                            // Handle failure (e.g., show error message)
                            print('Failed to remove product');
                          }
                        },
                        child: Container(
                          margin: EdgeInsets.all(getPercentSize(height, 12)),
                          child: Image.asset(
                            assetsPath + "trash.png",
                            height: getPercentSize(height, 17),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

Future<bool> removeFromCart(int productId) async {
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',  // Add token for authentication
    };

    final body = jsonEncode({
      'product_id': productId,
    });

    try {
      final response = await http.delete(Uri.parse(api_remove_from_cart), headers: headers, body: body);

      if (response.statusCode == 200) {
        // If removal is successful, return true
        return true;
      } else {
        print('Error removing product from cart: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Exception occurred while removing from cart: $e');
      return false;
    }
  }
  
  getCartButton(var icon, var color, var iconColor, Function function) {
    double height1 = getScreenPercentSize(context, 12);
    double height = getPercentSize(height1, 20);

    return InkWell(
      child: Container(
        height: height,
        width: height,
        child: Icon(
          icon,
          size: height,
          color: iconColor,
        ),
      ),
      onTap: () {
        function();
      },
    );
  }
}

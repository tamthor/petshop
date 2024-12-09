import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pet_shop/model/PetProductModel.dart';
import 'package:flutter_pet_shop/model/ProductOrderModel.dart';
import 'package:flutter_pet_shop/utils/Constant.dart';
import 'package:flutter_pet_shop/utils/CustomWidget.dart';
import 'package:flutter_pet_shop/utils/PrefData.dart';
import 'package:flutter_pet_shop/utils/SizeConfig.dart';
import 'repository/productorder_reponsitory.dart';

import 'MainPage.dart';

class MyOrderPage extends StatefulWidget {
  final bool isHomePage;

  MyOrderPage(this.isHomePage);

  @override
  _MyOrderPage createState() {
    return _MyOrderPage();
  }
}

class _MyOrderPage extends State<MyOrderPage>
    with SingleTickerProviderStateMixin {
  List<PetProduct> orderList = [];
  final ProductOrderRepository _productOrderRepository = ProductOrderRepository();

  bool isData = false;

  @override
  void initState() {
    super.initState();
    isDataAvailable();
    fetchUserOrders();
  }

  isDataAvailable() async {
    isData = await PrefData.getIsOrder();
    setState(() {});
  }

  Future<void> fetchUserOrders() async {
    try {
      List<ProductOrderModel> orders = await _productOrderRepository.fetchOrderedProducts();
      setState(() {
        orderList = orders.map((order) {
          return PetProduct.fromJson(order.toJson());
        }).toList();
        isData = orderList.isNotEmpty;
      });
    } catch (e) {
      print('Error fetching user orders: $e');
    }
  }

  Future<bool> _requestPop() {
    Navigator.of(context).pop();
    return new Future.value(true);
  }
  
  double defaultMargin = 0;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    double height = getScreenPercentSize(context, 11);
    double margin = getScreenPercentSize(context, 2);
    defaultMargin = getHorizontalSpace(context);

    double imageSize = getPercentSize(height, 100);
    double radius = getPercentSize(height, 15);

    return WillPopScope(
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          toolbarHeight: 0,
          backgroundColor: backgroundColor,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            getAppBar(context, "My Orders", isBack: true, function: () {
              _requestPop();
            }),
            SizedBox(height: getScreenPercentSize(context, 2),),
            Visibility(
              visible: isData,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: defaultMargin),
                child: getTextWithFontFamilyWidget("List of your orders", textColor, getScreenPercentSize(context, 2),
                    FontWeight.w500, TextAlign.center),
              ),
            ),
            SizedBox(height: getScreenPercentSize(context, 1),),
            Expanded(flex: 1,
              child: isData ? ListView.builder(
                primary: true,
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(horizontal: defaultMargin),
                itemCount: orderList.length,
                itemBuilder: (context, index) {
                  PetProduct order = orderList[index];
                  return getMaterialCell(context, widget: Text(order.toString()));
                },
              ) : emptyWidget(),
            ),
          ],
        ),
      ),
      onWillPop: _requestPop,
    );
  }

  emptyWidget() {
    PrefData.setIsOrder(true);
    double width = getWidthPercentSize(context, 45);
    double height = getScreenPercentSize(context, 7);
    return Container(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(assetsPath + "no_orders.png", height: getScreenPercentSize(context, 20),),
          SizedBox(height: getScreenPercentSize(context, 3),),
          getCustomTextWithFontFamilyWidget("No Orders Yet!",
              textColor, getScreenPercentSize(context, 2.5), FontWeight.w500, TextAlign.center, 1),
          SizedBox(height: getScreenPercentSize(context, 1),),
          getCustomTextWidget("Explore more and shortlist some products & Pets.",
              textColor, getScreenPercentSize(context, 2), FontWeight.w400, TextAlign.center, 1),
          InkWell(
            onTap: () {
              PrefData.setIsCart(true);
              Navigator.push(context, MaterialPageRoute(builder: (context) => MainPage(),));
            },
            child: getMaterialCell(context, widget: Container(
                margin: EdgeInsets.only(top: getScreenPercentSize(context, 4)),
                width: width,
                height: height,
                decoration: ShapeDecoration(
                  color: backgroundColor,
                  shadows: [
                    BoxShadow(
                        color: primaryColor.withOpacity(0.1),
                        blurRadius: 5,
                        spreadRadius: 5,
                        offset: Offset(0, 5))
                  ],
                  shape: SmoothRectangleBorder(
                    side: BorderSide(color: primaryColor, width: 1.5),
                    borderRadius: SmoothBorderRadius(
                      cornerRadius: getPercentSize(height, 25),
                      cornerSmoothing: 0.8,
                    ),
                  ),
                ),
                child: Center(
                  child: getCustomTextWidget("Go to Shop",
                      primaryColor, getPercentSize(width, 10), FontWeight.w600, TextAlign.center, 1),
                )
            )),
          )
        ],
      ),
    );
  }
}

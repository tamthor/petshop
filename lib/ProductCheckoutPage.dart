import 'package:flutter/material.dart';
import 'package:flutter_pet_shop/ProductConfirmationPage.dart';
import 'package:flutter_pet_shop/utils/Constant.dart';
import 'package:flutter_pet_shop/utils/CustomWidget.dart';
import 'package:flutter_pet_shop/utils/DataFile.dart';
import 'package:flutter_pet_shop/utils/SizeConfig.dart';

import 'customView/ReviewSlider.dart';
// import 'generated/l10n.dart';
// import 'model/AdressesModel.dart';
import 'model/PaymentCardModel.dart';
import 'model/AdressesModel.dart';
import 'model/PetProductModel.dart';

// import 'repository/address_repository.dart';

class ProductCheckoutPage extends StatefulWidget {
  final AddressModel selectedAddress;
  final List<PetProduct> petProducts;

  const ProductCheckoutPage({Key? key, required this.selectedAddress, required this.petProducts}) : super(key: key);

  @override
  _ProductCheckoutPage createState() {
    return _ProductCheckoutPage();
  }
}

class _ProductCheckoutPage extends State<ProductCheckoutPage> {

  int currentStep = 0;
  int _selectedPaymentMethod = 0; // 0 for card, 1 for cash on delivery, 2 for PayPal, 3 for Visa
  List<PaymentCardModel> paymentModelList = DataFile.getPaymentCardList();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds:  1), () {
      setThemePosition(context: context);
    });
    setState(() {});
  }


  Future<bool> _requestPop() {
    Navigator.of(context).pop();
    return new Future.value(true);
  }

  getOption() {
    return [
      'Address',
     'Payment',
      'Confirmation'
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
              Icon(Icons.warning, color: primaryColor),
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
    SizeConfig().init(context);
    double leftMargin = getHorizontalSpace(context);

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
                SizedBox(height: getScreenPercentSize(context, 1.5),),

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
                    options: getOption()),

                Expanded(flex: 1,
                  child: ListView(
                    children: [
                      Container(
                        padding: EdgeInsets.only(left: leftMargin, right: leftMargin),
                        child: Column(
                          children: [
                            SizedBox(height: getScreenPercentSize(context, 3),),

                            // Cash on Delivery
                            _buildPaymentOption(
                              context,
                              "Thanh toán khi nhận hàng",
                              Icons.money,
                              1,
                            ),

                            // PayPal
                            _buildPaymentOption(
                              context,
                              "PayPal",
                              Icons.payment, // Replace with PayPal icon
                              2,
                            ),

                            // Visa
                            _buildPaymentOption(
                              context,
                              "Visa",
                              Icons.credit_card, // Replace with Visa icon
                              3,
                            ),

                            // Bank Transfer
                            _buildPaymentOption(
                              context,
                              "Ngân hàng",
                              Icons.account_balance, // Replace with Bank icon
                              4,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  margin: EdgeInsets.only(top: getScreenPercentSize(context, 0.5)),
                  child: getButtonWidget(context, "Next", primaryColor, () {
                    if (_selectedPaymentMethod == 0) {
                      _showAlertDialog(context, "Thông báo", "Vui lòng chọn phương thức thanh toán.");
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductConfirmationPage(
                            selectedAddress: widget.selectedAddress,
                            petProducts: widget.petProducts,
                          ),
                        ),
                      );
                    }
                  }),
                )
              ],
            ),
          ),
        ),
        onWillPop: _requestPop);
  }

  Widget _buildPaymentOption(BuildContext context, String title, IconData icon, int value) {
    return InkWell(
      onTap: () {
        if (value == 2 || value == 3 || value == 4) { // PayPal, Visa, Bank
          _showUnsupportedPaymentDialog(context);
        } else {
          setState(() {
            _selectedPaymentMethod = value;
          });
        }
      },
      child: getMaterialCell(
        context,
        widget: Container(
          margin: EdgeInsets.only(bottom: getScreenPercentSize(context, 2)),
          padding: EdgeInsets.all(getScreenPercentSize(context, 2)),
          decoration: getDecorationWithRadius(getScreenPercentSize(context, 1.5), primaryColor),
          child: Row(
            children: [
              Radio<int>(
                value: value,
                groupValue: _selectedPaymentMethod,
                onChanged: (int? newValue) {
                  if (newValue == 2 || newValue == 3 || newValue == 4) {
                    _showUnsupportedPaymentDialog(context);
                  } else {
                    setState(() {
                      _selectedPaymentMethod = newValue!;
                    });
                  }
                },
              ),
              Icon(icon, color: primaryColor),
              SizedBox(width: 10),
              Expanded(
                child: getCustomTextWithoutAlignWithFontFamily(
                  title,
                  textColor,
                  FontWeight.w500,
                  getScreenPercentSize(context, 2.3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUnsupportedPaymentDialog(BuildContext context) {
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
              Text("Thông báo", style: TextStyle(color: primaryColor)),
            ],
          ),
          content: Text("Ứng dụng chưa hỗ trợ phương thức thanh toán này.", style: TextStyle(fontSize: 16)),
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

}

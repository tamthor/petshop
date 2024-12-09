import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pet_shop/MainPage.dart';
import 'package:flutter_pet_shop/PetDetailPage.dart';
// import 'package:flutter_pet_shop/model/ProductModel.dart';
import 'package:flutter_pet_shop/utils/Constant.dart';
import 'package:flutter_pet_shop/utils/CustomWidget.dart';
import 'package:flutter_pet_shop/utils/DataFile.dart';
import 'package:flutter_pet_shop/utils/PrefData.dart';
import 'package:flutter_pet_shop/utils/SizeConfig.dart';

import 'model/OrderDescModel.dart';
import 'model/pet.dart';

class MyAdoptionPage extends StatefulWidget {

  MyAdoptionPage();

  @override
  _MyAdoptionPage createState() {
    return _MyAdoptionPage();
  }
}

class _MyAdoptionPage extends State<MyAdoptionPage>
    with SingleTickerProviderStateMixin {
  List<Pet> myOrderList = DataFile.getAdoptModel().cast<Pet>();

    List<OrderDescModel> orderList = DataFile.getOrderDescList();
  // List<OrderModel> allOrderList = DataFile.getOrderList();


  void checkPermissions() async {}
  bool isData = false;

  @override
  void initState() {
    super.initState();
    isDataAvailable();
  }

  isDataAvailable() async {
    isData = await PrefData.getIsAdoptionPet();
    setState(() {});
  }


  Future<bool> _requestPop() {
    Navigator.of(context).pop();
    return new Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    double height = getScreenPercentSize(context, 11);
    double margin = getScreenPercentSize(context, 2);


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

              getAppBar(context, "My Adoptions",isBack: true,function: (){
                _requestPop();
              }),
              SizedBox(height: getScreenPercentSize(context, 2),),


              SizedBox(height: getScreenPercentSize(context, 1),),
              Expanded(flex: 1,
                child: !isData?emptyWidget():ListView.builder(
                  primary: true,
                  shrinkWrap: true,
                  padding: EdgeInsets.symmetric(horizontal: getHorizontalSpace(context)),
                  itemCount: (myOrderList.length> 3)?3:myOrderList.length,
                  itemBuilder: (context, index) {
                    Pet subCategoryModel = myOrderList[index];
                    String s="Delivered";
                    Color color="#2BBB4D".toColor();

                    if(index %4==0){
                      s="Pending";
                       color="#DE9C2B".toColor();
                    }else if(index %4==1){
                      s="Adopted";
                      color="#2BBB4D".toColor();
                    }else if(index %4==2){
                      s="Cancelled";
                      color="#FA001D".toColor();
                    }

                    return getMaterialCell(context,widget: InkWell(
                      onTap: (){
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PetDetailPage(petId: subCategoryModel.id.toString())));
                      },
                      child: Container(
                        decoration: getDecorationWithRadius(radius,primaryColor),
                        margin:
                        EdgeInsets.symmetric(vertical: getPercentSize(height, 10)),
                        width: double.infinity,
                        padding: EdgeInsets.all(
                          getPercentSize(height, 6),
                        ),
                        // height: itemHeight,
                        child: Row(
                          children: [
                            Container(
                              height: imageSize,
                              width: imageSize,
                              margin: EdgeInsets.only(right: (margin/2)),


                              child: Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadiusDirectional.circular(radius)),
                                clipBehavior: Clip.antiAlias,
                                child: Image.asset(
                                  assetsPath + subCategoryModel.image,
                                  fit: BoxFit.fill,

                                ),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: getCustomTextWithFontFamilyWidget(
                                            subCategoryModel.name,
                                            textColor,
                                            getPercentSize(height, 18),
                                            FontWeight.w500, TextAlign.start,
                                            1),flex: 1,
                                      ),
                                      getCustomTextWidget(
                                          '25-02-2022',
                                          subTextColor,
                                          getPercentSize(height, 18),
                                          FontWeight.w400, TextAlign.start,
                                          1)

                                    ],
                                  ),


                                  SizedBox(
                                    height: getPercentSize(height, 7),
                                  ),

                                  getCustomTextWidget(
                                      '\$${subCategoryModel.price.toStringAsFixed(2)}',
                                      textColor,
                                      getPercentSize(height, 18),
                                      FontWeight.w400,
                                      TextAlign.start,
                                      1),


                                  SizedBox(
                                    height: getPercentSize(height, 9),
                                  ),

                                  Row(
                                    children: [
                                      Expanded(
                                        child: getCustomTextWidget(
                                            '\$${subCategoryModel.price.toStringAsFixed(2)}',
                                            primaryColor,
                                            getPercentSize(height, 18),
                                            FontWeight.w600,
                                            TextAlign.start,
                                            1),flex: 1,
                                      ),

                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: getWidthPercentSize(context,2),
                                            vertical: getPercentSize(height, 4)),

                                        decoration: ShapeDecoration(
                                          color: color.withOpacity(0.1),

                                          shape: SmoothRectangleBorder(
                                            side: BorderSide(color: iconColor, width: 0.1),
                                            borderRadius: SmoothBorderRadius(
                                              cornerRadius: radius,
                                              cornerSmoothing: 0.8,
                                            ),
                                          ),
                                        ),
                                        child: getCustomTextWithFontFamilyWidget(
                                            s,
                                            color,
                                            getPercentSize(height, 16),
                                            FontWeight.w400,
                                            TextAlign.start,
                                            1),
                                      )

                                    ],
                                  )


                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ));
                  },
                ),
              ),


            ],
          ),

        ),
        onWillPop: _requestPop);
  }
  emptyWidget() {
    double width = getWidthPercentSize(context, 45);
    double height = getScreenPercentSize(context, 7);
    return Container(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            assetsPath + "drop.png",
            height: getScreenPercentSize(context, 20),
          ),
          SizedBox(
            height: getScreenPercentSize(context, 3),
          ),
          getCustomTextWithFontFamilyWidget(
              "No Adoption Yet!",
              textColor,
              getScreenPercentSize(context, 2.5),
              FontWeight.w500,
              TextAlign.center,
              1),
          SizedBox(
            height: getScreenPercentSize(context, 1),
          ),
          getCustomTextWidget(
              "Explore more and shortlist some pets.",
              textColor,
              getScreenPercentSize(context, 2),
              FontWeight.w400,
              TextAlign.center,
              1),
          InkWell(
            onTap: () {
              PrefData.setIsAdoptionPet(true);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MainPage(tabPosition: 3),
                  )).then((value) => isDataAvailable());
            },
            child: getMaterialCell(context,widget: Container(
                margin: EdgeInsets.only(top: getScreenPercentSize(context, 4)),
                width: width,
                height: height,
                decoration: ShapeDecoration(
                  color: backgroundColor,
                  // shadows: [
                  //   BoxShadow(
                  //       color: primaryColor.withOpacity(0.1),
                  //       blurRadius: 5,
                  //       spreadRadius: 5,
                  //       offset: Offset(0, 5))
                  // ],
                  shape: SmoothRectangleBorder(
                    side: BorderSide(color: primaryColor, width: 1.5),
                    borderRadius: SmoothBorderRadius(
                      cornerRadius: getPercentSize(height, 25),
                      cornerSmoothing: 0.8,
                    ),
                  ),
                ),
                child: Center(
                  child: getCustomTextWidget(
                      "Go To Shop",
                      primaryColor,
                      getPercentSize(width, 10),
                      FontWeight.w600,
                      TextAlign.center,
                      1),
                ))),
          )
        ],
      ),
    );
  }


}

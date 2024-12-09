import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_pet_shop/MainPage.dart';
import 'package:flutter_pet_shop/utils/Constant.dart';
import 'package:flutter_pet_shop/utils/CustomWidget.dart';
import 'package:flutter_pet_shop/utils/SizeConfig.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/product_providers.dart';
import '../model/PetProductModel.dart';
import '../ProductDetailPage.dart';

class ShopPage extends ConsumerStatefulWidget {
  final Function? function;
  
  ShopPage({this.function});

  @override
  _ShopPage createState() => _ShopPage();
}

class _ShopPage extends ConsumerState<ShopPage> {
  @override
  Widget build(BuildContext context) {
    final petproductAsync = ref.watch(petproductListProvider);
    
    SizeConfig().init(context);
    double height = getScreenPercentSize(context, 3);
    defMargin = getHorizontalSpace(context);

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
              getAppBar(context, "All Products", isBack: true, function: () {
                _requestPop();
              },widget: InkWell(
                // onTap: () {
                //   Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //         builder: (context) => MainPage(),
                //       ));
                // },
                child: getSubMaterialCell(context, widget: Container(

                  height: height,
                  width: height,
                  decoration: getDecorationWithColor(
                      getPercentSize(height, 25), primaryColor),
                  child: Center(
                    child: Icon(Icons.add,
                        color: const Color.fromARGB(255, 118, 118, 198), size: getPercentSize(height, 70)),
                  ),
                ),),
              )),
              SizedBox(
                height: getScreenPercentSize(context, 1.5),
              ),
              Expanded(
                child: petproductAsync.when(
                  loading: () => Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Error: $err')),
                  data: (petproducts) => sellerList(petproducts),
                ),
              ),
            ],
          ),
        ),
      ),
      onWillPop: _requestPop,
    );
  }

  Future<bool> _requestPop() {
    if (widget.function != null) {
      widget.function!();
    } else {
      Navigator.of(context).pop();
    }

    return new Future.value(true);
  }

  void doNothing(BuildContext context) {}

  double defMargin = 0;

  Widget sellerList(List<PetProduct> petproducts) {
    var height = getScreenPercentSize(context, 40);
    double width = getWidthPercentSize(context, 40);
    double imgHeight = getPercentSize(height, 50);
    double remainHeight = height - imgHeight;

    double radius = getPercentSize(height, 5);

    double _crossAxisSpacing = 0;
    var _screenWidth = MediaQuery.of(context).size.width;
    var _crossAxisCount = 2;
    var _width = (_screenWidth - ((_crossAxisCount - 1) * _crossAxisSpacing)) /
        _crossAxisCount;

    var _aspectRatio = _width / height;

    return GridView.count(
      crossAxisCount: _crossAxisCount,
      shrinkWrap: true,
      padding: EdgeInsets.symmetric(horizontal: (defMargin)),
      scrollDirection: Axis.vertical,
      primary: false,
      crossAxisSpacing: (defMargin),
      mainAxisSpacing: 0,
      childAspectRatio: _aspectRatio,
      children: List.generate(petproducts.length, (index) {
        PetProduct petProduct = petproducts[index];

        return InkWell(
          child: getMaterialCell(context,widget: Container(
            width: width,
            margin: EdgeInsets.symmetric(vertical: (defMargin/1.5)),
            decoration: ShapeDecoration(
              color: backgroundColor,


              shape: SmoothRectangleBorder(

                borderRadius: SmoothBorderRadius(
                  cornerRadius: radius,
                  cornerSmoothing: 0.8,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: imgHeight,
                  margin: EdgeInsets.only(top: getPercentSize(width, 6)),
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.topCenter,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(radius),
                          child: Column(
                            children: [
                              // Debug: In ra URL ảnh
                              // Text('Image URL: ${pet.image}'),
                              Image.network(
                                petProduct.photo,
                                width: width,
                                height: imgHeight,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  print('Error loading image: $error');
                                  return Container(
                                    width: width,
                                    height: imgHeight,
                                    color: const Color.fromARGB(255, 255, 255, 255),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.pets,
                                          size: 50,
                                          color: const Color.fromARGB(255, 103, 75, 153),
                                        ),
                                        Text('Image not found'),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(
                      left: getPercentSize(width, 5),
                      bottom: getPercentSize(width, 6),
                      right: getPercentSize(width, 5),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        getCustomTextWidget(
                          petProduct.title,
                          textColor,
                          getPercentSize(remainHeight, 11),
                          FontWeight.w900,
                          TextAlign.start,
                          1,
                        ),
                        SizedBox(
                          height: getPercentSize(remainHeight, 4),
                        ),
                        getCustomTextWidget(
                          '${petProduct.price} vnđ',
                          primaryColor,
                          getPercentSize(remainHeight, 10),
                          FontWeight.bold,
                          TextAlign.start,
                          1,
                        ),
                        SizedBox(
                          height: getPercentSize(remainHeight, 4),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              assetsPath + "splash_icon.png",
                              height: getPercentSize(remainHeight, 10),
                            ),
                            SizedBox(
                              width: getPercentSize(width, 2),
                            ),
                            Expanded(
                              child: getCustomTextWidget(
                                petProduct.summary.length > 20 ? petProduct.summary.substring(0, 20) + '...' : petProduct.summary,
                                textColor,
                                getPercentSize(remainHeight, 9.4),
                                FontWeight.w500,
                                TextAlign.start,
                                1),
                            ),
                          ],
                        ),
                        Expanded(child: Container(),flex: 1,),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )),
          onTap: () {
            // In ra ID để debug
            print('Selected pet ID: ${petProduct.id}');
            
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailPage(
                  productId: petProduct.id.toString(),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

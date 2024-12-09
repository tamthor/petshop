import 'package:carousel_slider/carousel_slider.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pet_shop/PetDetailPage.dart';
import 'package:flutter_pet_shop/ProductDetailPage.dart';
import 'package:flutter_pet_shop/model/DataModel.dart';
import 'package:flutter_pet_shop/utils/Constant.dart';
import 'package:flutter_pet_shop/utils/CustomWidget.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constant/apilist.dart';
import '../NotificationList.dart';
import '../ShopPage.dart';
import '../AllPetPage.dart';
import '../PetService.dart';
import '../CategoryDetailPage.dart';
import '../model/pet.dart';
import '../model/PetProductModel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/pet_provider.dart';
import '../providers/product_providers.dart';

class HomeWidget extends ConsumerStatefulWidget {
  final Function function;
  final Function? functionViewAll;
  final Function? functionAdoptionAll;

  HomeWidget(this.function, {this.functionViewAll,this.functionAdoptionAll});

  @override
  _HomeWidget createState() {
    return _HomeWidget();
  }
}

class _HomeWidget extends ConsumerState<HomeWidget> {
  double defMargin = 0;
  double padding = 0;
  double height = 0;
  List<DataModel> dataList = [
    DataModel(id: 1, image: 'pet_4.png', name: 'Dog'),
    DataModel(id: 2, image: 'pet_6.png', name: 'Cat'),
    // Thêm các danh mục khác với id
  ];
  List<Pet> adoptList = [];
  FocusNode myFocusNode = FocusNode();
  bool isAutoFocus = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPets();
  }
  Future<void> fetchPetsByCategory(int categoryId) async {
    setState(() {
      isLoading = true;
    });

    try {
      List<Pet> pets = await PetService().fetchPetsByCategory(categoryId);
      setState(() {
        adoptList = pets;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching pets: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchPets() async {
    try {
      final response = await http.get(Uri.parse(api_pets));
      print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> data = jsonResponse['data'] ?? [];
        setState(() {
          adoptList = data.map((json) => Pet.fromJson(json)).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching pets: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    defMargin = getHorizontalSpace(context);
    // defMargin = getScreenPercentSize(context, 2.5);
    padding = getScreenPercentSize(context, 2);
    height = getScreenPercentSize(context, 5.7);
    // height = getScreenPercentSize(context, 5.5);
    double radius = getScreenPercentSize(context, 1.5);
    double btnHeight = getScreenPercentSize(context, 13);

    final petsAsync = ref.watch(petListProvider);

    return Container(
      color: backgroundColor,
      padding: EdgeInsets.only(top: getScreenPercentSize(context, 2)),
      child: GestureDetector(
        onTap: () {
          setState(() {
            myFocusNode.canRequestFocus = false;
          });
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            getAppBar(),
            Expanded(
              child: ListView(
                children: [
                  SizedBox(
                    height: defMargin,
                  ),
                  // Padding(
                  //   padding: EdgeInsets.symmetric(horizontal: defMargin),
                  //   child: getCustomTextWithFontFamilyWidget(
                  //       'Adopt a Friend',
                  //       textColor,
                  //       getScreenPercentSize(context, 2.5),
                  //       FontWeight.w500,
                  //       TextAlign.start,
                  //       1),
                  // ),
                  Row(
                    children: [
                      SizedBox(
                        width: defMargin,
                      ),
                      Expanded(
                        child: StatefulBuilder(
                          builder: (context, setState) {
                            return Container(
                              height: height,
                              margin: EdgeInsets.symmetric(
                                  vertical: (defMargin / 2)),
                              decoration: getDecorationWithBorder(radius,
                                  color:
                                      isAutoFocus ? primaryColor : borderColor),
                              child: Focus(
                                onFocusChange: (hasFocus) {
                                  if (hasFocus) {
                                    setState(() {
                                      isAutoFocus = true;
                                    });
                                  } else {
                                    setState(() {
                                      isAutoFocus = false;
                                    });
                                  }
                                },
                                child: TextField(
                                  focusNode: myFocusNode,
                                  autofocus: false,
                                  style: TextStyle(
                                    fontFamily: fontFamily,
                                    color: textColor,
                                    fontWeight: FontWeight.w400,
                                    fontSize: getScreenPercentSize(context, 2),
                                  ),
                                  onChanged: (string) {},
                                  maxLines: 1,
                                  textAlignVertical: TextAlignVertical.center,
                                  textAlign: TextAlign.left,
                                  decoration: InputDecoration(
                                      contentPadding:
                                          EdgeInsets.only(left: defMargin),
                                      hintText: 'Search...',
                                      prefixIcon: Icon(
                                        CupertinoIcons.search,
                                        color: subTextColor,
                                        size: getPercentSize(height, 50),
                                      ),
                                      hintStyle: TextStyle(
                                        color: subTextColor,
                                        fontFamily: fontFamily,
                                        fontSize:
                                            getScreenPercentSize(context, 2),
                                        fontWeight: FontWeight.w400,
                                      ),
                                      filled: true,
                                      fillColor: Colors.transparent,
                                      disabledBorder: getOutLineBorder(radius),
                                      enabledBorder: getOutLineBorder(radius),
                                      focusedBorder: getOutLineBorder(radius),
                                      isDense: true),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        width: (defMargin),
                      ),
                    ],
                  ),
                  getSlider(),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ShopPage(),
                                ));
                          },
                          child: getSubMaterialCell(
                            context,
                            widget: Container(
                              height: btnHeight,
                              margin: EdgeInsets.only(
                                  left: defMargin, right: (defMargin / 2)),
                              decoration:
                                  getDecorationWithRadius(radius, primaryColor),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    assetsPath + "Group 33638.png",
                                    height: getPercentSize(btnHeight, 40),
                                  ),
                                  SizedBox(
                                    height: getPercentSize(btnHeight, 7),
                                  ),
                                  getTextWithFontFamilyWidget(
                                      'Shop',
                                      textColor,
                                      getPercentSize(btnHeight, 12),
                                      FontWeight.w500,
                                      TextAlign.start)
                                ],
                              ),
                            ),
                          ),
                        ),
                        flex: 1,
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            widget.function();
                          },
                          child: getSubMaterialCell(
                            context,
                            widget: Container(
                              height: btnHeight,
                              margin: EdgeInsets.only(
                                  right: defMargin, left: (defMargin / 2)),
                              decoration:
                                  getDecorationWithRadius(radius, primaryColor),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    assetsPath + "dog-4 1.png",
                                    height: getPercentSize(btnHeight, 40),
                                  ),
                                  SizedBox(
                                    height: getPercentSize(btnHeight, 7),
                                  ),
                                  getTextWithFontFamilyWidget(
                                      'Pet Adoptions',
                                      textColor,
                                      getPercentSize(btnHeight, 12),
                                      FontWeight.w500,
                                      TextAlign.start)
                                ],
                              ),
                            ),
                          ),
                        ),
                        flex: 1,
                      )
                    ],
                  ),
                  SizedBox(
                    height: getScreenPercentSize(context, 3),
                  ),
                  getTitle('Categories', function: widget.functionViewAll!),
                  getCategoryList(),
                  SizedBox(
                    height: getScreenPercentSize(context, 1),
                  ),
                  getTitle('Our Picks for you',
                      function: widget.functionAdoptionAll!),
                  gridList(),
                  SizedBox(
                    height: getScreenPercentSize(context, 1),
                  ),
                  getTitle('Our Picks for you',
                      function: widget.functionAdoptionAll!),
                  gridProductList()
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
  Widget gridProductList() {
    var height = getScreenPercentSize(context, 30);
    double width = getWidthPercentSize(context, 40);
    double imgHeight = getPercentSize(height, 50);
    double radius = getPercentSize(height, 5);

    return Consumer(
      builder: (context, ref, child) {
        final petproductsAsync = ref.watch(petproductListProvider);

        return Container(
          height: height,
          child: petproductsAsync.when(
            loading: () => Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
            data: (petProducts) => ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: petProducts.length,
              itemBuilder: (context, index) {
                PetProduct petProduct = petProducts[index];

                return InkWell(
                  child: Container(
                    width: width,
                    margin: EdgeInsets.only(
                      left: index == 0 ? defMargin : defMargin / 2,
                      right: index == petProducts.length - 1 ? defMargin : defMargin / 2,
                    ),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(radius),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image Container with gradient overlay
                        Stack(
                          children: [
                            Container(
                              height: imgHeight,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(radius),
                                  topRight: Radius.circular(radius),
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(radius),
                                  topRight: Radius.circular(radius),
                                ),
                                child: Image.network(
                                  petProduct.photo,
                                  width: width,
                                  height: imgHeight,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      color: Colors.grey[200],
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                                        ),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: width,
                                      height: imgHeight,
                                      color: Colors.grey[200],
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.pets,
                                            size: 40,
                                            color: Colors.grey[400],
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            'Image not available',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            // Gradient overlay
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              height: imgHeight / 3,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(radius),
                                    topRight: Radius.circular(radius),
                                  ),
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Colors.black.withOpacity(0.4),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        // Content Container
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Name and Price
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        petProduct.title,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: textColor,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: primaryColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${petProduct.price} vnđ',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: primaryColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                
                                SizedBox(height: 8),
                                
                                // Description
                                Text(
                                  petProduct.summary,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    height: 1.5,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                
                                // Adopt button
                                Spacer(),
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: primaryColor,
                                    borderRadius: BorderRadius.circular(radius / 2),
                                  ),
                                  child: Text(
                                    'Buy Now',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
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
                  onTap: () {
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
              },
            ),
          ),
        );
      },
    );
  }
  Widget gridList() {
    var height = getScreenPercentSize(context, 30);
    double width = getWidthPercentSize(context, 40);
    double imgHeight = getPercentSize(height, 50);
    double radius = getPercentSize(height, 5);

    return Consumer(
      builder: (context, ref, child) {
        final petsAsync = ref.watch(petListProvider);

        return Container(
          height: height,
          child: petsAsync.when(
            loading: () => Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
            data: (pets) => ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: pets.length,
              itemBuilder: (context, index) {
                Pet pet = pets[index];

                return InkWell(
                  child: Container(
                    width: width,
                    margin: EdgeInsets.only(
                      left: index == 0 ? defMargin : defMargin / 2,
                      right: index == pets.length - 1 ? defMargin : defMargin / 2,
                    ),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(radius),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image Container with gradient overlay
                        Stack(
                          children: [
                            Container(
                              height: imgHeight,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(radius),
                                  topRight: Radius.circular(radius),
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(radius),
                                  topRight: Radius.circular(radius),
                                ),
                                child: Image.network(
                                  pet.image,
                                  width: width,
                                  height: imgHeight,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      color: Colors.grey[200],
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                                        ),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: width,
                                      height: imgHeight,
                                      color: Colors.grey[200],
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.pets,
                                            size: 40,
                                            color: Colors.grey[400],
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            'Image not available',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            // Gradient overlay
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              height: imgHeight / 3,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(radius),
                                    topRight: Radius.circular(radius),
                                  ),
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Colors.black.withOpacity(0.4),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        // Content Container
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Name and Price
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        pet.name,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: textColor,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: primaryColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${pet.price} vnđ',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: primaryColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                
                                SizedBox(height: 8),
                                
                                // Description
                                Text(
                                  pet.description,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    height: 1.5,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                
                                // Adopt button
                                Spacer(),
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: primaryColor,
                                    borderRadius: BorderRadius.circular(radius / 2),
                                  ),
                                  child: Text(
                                    'Adopt Now',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
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
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PetDetailPage(
                          petId: pet.id.toString(),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  List<String> list = [
    "Latest Products",
    "Best Selling",
    "Lowest Price",
    "Highest Price"
  ];

  int position = 0;

  filterDialog() {
    double height = getScreenPercentSize(context, 45);
    double radius = getScreenPercentSize(context, 3);
    double subHeight = getPercentSize(height, 14.5);

    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(radius),
                topRight: Radius.circular(radius))),
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return Container(
                height: height,
                padding: EdgeInsets.all(getScreenPercentSize(context, 2)),
                child: ListView(
                  children: <Widget>[
                    Row(
                      children: [
                        Expanded(
                          child: getTextWithFontFamilyWidget(
                              'Sort By',
                              textColor,
                              getPercentSize(height, 5),
                              FontWeight.w500,
                              TextAlign.start),
                          flex: 1,
                        ),
                        InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Icon(
                              Icons.close,
                              size: getPercentSize(height, 6),
                              color: textColor,
                            )),
                      ],
                    ),
                    SizedBox(
                      height: getPercentSize(height, 1),
                    ),
                    getTextWidget(
                        'Arrange based on the following types',
                        subTextColor,
                        getPercentSize(height, 3.5),
                        FontWeight.w400,
                        TextAlign.start),
                    SizedBox(
                      height: getPercentSize(height, 2),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: list.length,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            // setState(() {
                            // position=index;
                            Navigator.of(context).pop();
                            filterDialog1();
                            // });
                          },
                          child: Container(
                            height: subHeight,
                            margin: EdgeInsets.symmetric(
                                vertical: getPercentSize(height, 2)),
                            padding: EdgeInsets.symmetric(
                                horizontal: getWidthPercentSize(context, 3)),
                            decoration: ShapeDecoration(
                              color: cellColor,
                              shape: SmoothRectangleBorder(
                                side: BorderSide(
                                    color: primaryColor.withOpacity(0.5),
                                    width: 0.3),
                                borderRadius: SmoothBorderRadius(
                                  cornerRadius: getPercentSize(subHeight, 25),
                                  cornerSmoothing: 0.8,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: getTextWidget(
                                      list[index],
                                      textColor,
                                      getPercentSize(subHeight, 27),
                                      FontWeight.w400,
                                      TextAlign.start),
                                  flex: 1,
                                ),
                                Visibility(
                                  visible: (position == index),
                                  child: Icon(
                                    Icons.check_circle,
                                    size: getPercentSize(subHeight, 35),
                                    color: primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  ],
                ),
              );
            },
          );
        });
  }


  RangeValues _currentRangeValues = const RangeValues(100, 1000);

  filterDialog1() {
    double height = getScreenPercentSize(context, 45);
    double radius = getScreenPercentSize(context, 3);
    double margin = getScreenPercentSize(context, 2);

    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(radius),
                topRight: Radius.circular(radius))),
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return FractionallySizedBox(
                heightFactor: 0.6,
                child: Container(
                  // Add padding to avoid bottom overflow
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom + margin
                  ),
                  child: ListView(
                    // Add physics to handle overflow gracefully
                    physics: ClampingScrollPhysics(),
                    children: <Widget>[
                      SizedBox(
                        height: margin,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: margin),
                        child: Row(
                          children: [
                            Expanded(
                              child: getTextWithFontFamilyWidget(
                                  'Filter',
                                  textColor,
                                  getPercentSize(height, 5),
                                  FontWeight.w500,
                                  TextAlign.start),
                              flex: 1,
                            ),
                            InkWell(
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                                child: Icon(
                                  Icons.close,
                                  size: getPercentSize(height, 6),
                                  color: textColor,
                                )),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: getPercentSize(height, 1),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: margin),
                        child: getTextWidget(
                            'Filter products with more specific types',
                            subTextColor,
                            getPercentSize(height, 3.5),
                            FontWeight.w400,
                            TextAlign.start),
                      ),
                      SizedBox(
                        height: getPercentSize(height, 4),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: margin),
                        child: getTextWithFontFamilyWidget(
                            'Price',
                            textColor,
                            getPercentSize(height, 4),
                            FontWeight.w500,
                            TextAlign.start),
                      ),
                      SizedBox(
                        height: getPercentSize(height, 2),
                      ),
                      RangeSlider(
                        values: _currentRangeValues,
                        min: 10,
                        max: 1000,
                        activeColor: primaryColor,
                        inactiveColor: primaryColor.withOpacity(0.5),
                        onChanged: (RangeValues values) {
                          setState(() {
                            _currentRangeValues = values;
                          });
                        },
                      ),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: margin),
                        child: Row(
                          children: [
                            Expanded(
                              child: getTextWidget(
                                  "\$50",
                                  primaryColor,
                                  getScreenPercentSize(context, 2),
                                  FontWeight.w600,
                                  TextAlign.start),
                            ),

                            getTextWidget(
                                "\$250",
                                primaryColor,
                                getScreenPercentSize(context, 2),
                                FontWeight.w600,
                                TextAlign.start),

                            // getTextWidget(
                            //     '\$1000',
                            //     disableIconColor,
                            //     TextAlign.start,
                            //     FontWeight.w600,
                            //     getScreenPercentSize(context, 2))
                          ],
                        ),
                      ),

                      SizedBox(
                        height: getScreenPercentSize(context, 3),
                      ),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: margin),
                        child: getTextWithFontFamilyWidget(
                            'Brand',
                            textColor,
                            getPercentSize(height, 4),
                            FontWeight.w500,
                            TextAlign.start),
                      ),
                      SizedBox(
                        height: getPercentSize(height, 2),
                      ),

                      Padding(
                          padding: EdgeInsets.symmetric(horizontal: margin),
                          child: getGrid(setState)),
                      SizedBox(
                        height: getPercentSize(height, 10),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: margin),
                        child: Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  // Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpPage(),));
                                },
                                child: getMaterialCell(context,
                                    widget: Container(
                                      margin: EdgeInsets.only(
                                          right:
                                              getWidthPercentSize(context, 3)),
                                      height: getScreenPercentSize(context, 7),
                                      decoration: ShapeDecoration(
                                        color: alphaColor,
                                        // shadows: [
                                        //   BoxShadow(
                                        //       color: textColor.withOpacity(0.1),
                                        //       blurRadius: 2,
                                        //       spreadRadius: 1,
                                        //       offset: Offset(0, 4))
                                        // ],
                                        shape: SmoothRectangleBorder(
                                          side: BorderSide(
                                              color: primaryColor, width: 2),
                                          borderRadius: SmoothBorderRadius(
                                            cornerRadius: getScreenPercentSize(
                                                context, 1.8),
                                            cornerSmoothing: 0.8,
                                          ),
                                        ),
                                      ),
                                      child: Center(
                                        child: getTextWidget(
                                            'Reset',
                                            textColor,
                                            getScreenPercentSize(context, 2),
                                            FontWeight.bold,
                                            TextAlign.center),
                                      ),
                                    )),
                              ),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  // if(_position==3){
                                  //   PrefData.setIsIntro(false);
                                  //   Navigator.push(context, MaterialPageRoute(builder: (context) => SignInPage(),));
                                  // }else {
                                  //   if (_position < (introModelList.length - 1)) {
                                  //     setState(() {
                                  //       _position = _position + 1;
                                  //       controller.jumpToPage(_position);
                                  //     });
                                  //   } else {
                                  //     skip();
                                  //   }
                                  // }
                                },
                                child: getMaterialCell(context,
                                    widget: Container(
                                      margin: EdgeInsets.only(
                                          left:
                                              getWidthPercentSize(context, 3)),
                                      height: getScreenPercentSize(context, 7),
                                      decoration: ShapeDecoration(
                                        color: primaryColor,
                                        // shadows: [BoxShadow(
                                        //     color: textColor.withOpacity(0.1),
                                        //     blurRadius: 2,
                                        //     spreadRadius: 1,
                                        //     offset: Offset(0, 4))],
                                        shape: SmoothRectangleBorder(
                                          borderRadius: SmoothBorderRadius(
                                            cornerRadius: getScreenPercentSize(
                                                context, 1.8),
                                            cornerSmoothing: 0.8,
                                          ),
                                        ),
                                      ),
                                      child: Center(
                                        child: getTextWidget(
                                            'Apply',
                                            Colors.white,
                                            getScreenPercentSize(context, 2),
                                            FontWeight.bold,
                                            TextAlign.center),
                                      ),
                                    )),
                              ),
                            )
                          ],
                        ),
                      ),

                      SizedBox(
                        height: getPercentSize(height, 10),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        });
  }

  List<String> materialList = [
    'King',
    'Pedigree',
    'Baker',
    'Whiskies',
    'Chomp',
    'Pet Toys',
    'Meow',
    'Bash',
    'Domino'
  ];

  int materialPosition = 0;

  getGrid(var setState) {
    var _crossAxisSpacing = 1;
    var _screenWidth = MediaQuery.of(context).size.width;
    var _crossAxisCount = 3;
    var _width = (_screenWidth - ((_crossAxisCount - 1) * _crossAxisSpacing)) /
        _crossAxisCount;
    var cellHeight = getScreenPercentSize(context, 5.5);

    var margin = getWidthPercentSize(context, 3);

    var _aspectRatio = _width / cellHeight;

    return Container(
      margin: EdgeInsets.only(right: 1),
      child: GridView.count(
        crossAxisCount: _crossAxisCount,
        shrinkWrap: true,
        childAspectRatio: _aspectRatio,
        mainAxisSpacing: margin,
        crossAxisSpacing: (margin),
        // childAspectRatio: 0.64,
        primary: false,
        children: List.generate(materialList.length, (index) {
          return InkWell(
            onTap: () {
              setState(() {
                materialPosition = index;
              });
            },
            child: Container(
              width: cellHeight,
              child: Container(
                margin: EdgeInsets.only(
                    top: getPercentSize(cellHeight, 3), bottom: 1),
                height: double.infinity,
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                    horizontal: getWidthPercentSize(context, 3)),
                decoration: ShapeDecoration(
                  color:
                      (materialPosition == index) ? primaryColor : alphaColor,
                  shape: SmoothRectangleBorder(
                    side: BorderSide(color: iconColor, width: 0.3),
                    borderRadius: SmoothBorderRadius(
                      cornerRadius: getPercentSize(cellHeight, 15),
                      cornerSmoothing: 0.8,
                    ),
                  ),
                ),
                child: Center(
                  child: getTextWidget(
                    materialList[index],
                    (index == materialPosition) ? Colors.white : textColor,
                    getPercentSize(cellHeight, 30),
                    FontWeight.w500,
                    TextAlign.center,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  int selectedCategory = 0;
  void onCategorySelected(int index) {
  int categoryId = dataList[index].id; // Giả sử mỗi category có một ID
  fetchPetsByCategory(categoryId);
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => CategoryDetailPage(categoryId: categoryId),
    ),
  );
}
  getCategoryList() {
    double height = getScreenPercentSize(context, 7);
    double width = getWidthPercentSize(context, 30);
    return Container(
        height: height,
        margin: EdgeInsets.symmetric(vertical: padding),
        child: ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: dataList.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              Color color = "#F1DDD3".toColor();

              if (index % 3 == 0) {
                color = "#F7E1BD".toColor();
              } else if (index % 3 == 1) {
                color = "#DBF0E5".toColor();
              } else if (index % 3 == 2) {
                color = "#F1DDD3".toColor();
              }
              return InkWell(
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: selectedCategory == index
                              ? primaryColor
                              : Colors.transparent,
                          width: selectedCategory == index ? 1 : 0),
                      borderRadius: BorderRadius.all(
                          Radius.circular(getPercentSize(height, 50)))),
                  margin: EdgeInsets.only(
                      left: index == 0 ? (defMargin) : (defMargin / 1.5)),
                  child: Container(
                    margin: EdgeInsets.all(1),

                    width: width,

                    decoration: ShapeDecoration(
                      color: color,
                      shape: SmoothRectangleBorder(
                        // side: BorderSide(color: primaryColor,width: selectedCategory==index?1:0),

                        borderRadius: SmoothBorderRadius(
                          cornerRadius: getPercentSize(height, 50),
                          cornerSmoothing: 0.8,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: height,
                          width: height,
                          decoration: BoxDecoration(
                            color: Colors.white54,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Image.asset(
                              assetsPath + dataList[index].image!,
                              height: getPercentSize(height, 60),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: getPercentSize(width, 10),
                        ),
                        Expanded(
                            child: getCustomTextWidget(
                                dataList[index].name!,
                                Colors.black,
                                getPercentSize(width - height, 22),
                                FontWeight.w500,
                                TextAlign.start,
                                1))
                      ],
                    ),

                  ),
                ),
                onTap: () {
                  setState(() {
                    selectedCategory = index;
                  });
                  onCategorySelected(index);
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) => SubCategoriesPage()));
                },
              );
            }));
  }

  getTitle(String s, {Function? function}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: defMargin),
      child: Row(
        children: [
          Expanded(
            child: getTextWithFontFamilyWidget(
                s,
                textColor,
                getScreenPercentSize(context, 2),
                FontWeight.w500,
                TextAlign.start),
          ),
          InkWell(
            onTap: () {
              if (function != null) {
                function();
              }
            },
            child: getTextWidget(
                'View All',
                primaryColor,
                getScreenPercentSize(context, 1.6),
                FontWeight.w500,
                TextAlign.start),
          )
        ],
      ),
    );
  }

  getAppBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: defMargin),
      child: Row(
        children: [
          Expanded(
            child: getCustomTextWithFontFamilyWidget(
                'Adopt a Friend',
                textColor,
                getScreenPercentSize(context, 2.5),
                FontWeight.w500,
                TextAlign.start,
                1),
          ),
          InkWell(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder:  (context) => NotificationList(),));
            },
            child: Image.asset(
              assetsPath + "notifications.png",
              height: getScreenPercentSize(context, 2.5),
              color: textColor,
            ),
          ),

        ],
      ),
    );
  }

  getSlider() {
    double sliderHeight = getScreenPercentSize(context, 22);

    return Container(
      width: double.infinity,
      height: sliderHeight,
      child: CarouselSlider.builder(
        itemCount: 3,
        options:
            CarouselOptions(autoPlay: true, onPageChanged: (index, reason) {}),
        itemBuilder: (context, index, realIndex) {
          Color color = "#F1DDD3".toColor();

          if (index % 2 == 0) {
            color = Colors.green.shade200;
          } else if (index % 2 == 1) {
            color = Colors.orangeAccent.shade100;
          }

          if (index == 0) {
            return getBanner(sliderHeight, 'pet_3.png');
          } else if (index == 1) {
            return getSliderCell(sliderHeight, color);
          } else {
            return getBanner(sliderHeight, 'pet_6.png', color: color);
          }
        },
      ),
    );
  }

  Color darken(Color c, [int percent = 10]) {
    assert(1 <= percent && percent <= 100);
    var f = 1 - percent / 100;
    return Color.fromARGB(c.alpha, (c.red * f).round(), (c.green * f).round(),
        (c.blue * f).round());
  }

  getSliderCell(double height, Color color) {
    // Color color = "#A193E2".toColor();
    double width = double.infinity;

    double radius = getPercentSize(height, 7);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(radius)),
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.5), color.withOpacity(0.9), color])),
      margin:
          EdgeInsets.symmetric(vertical: defMargin, horizontal: (padding / 2)),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(right: padding),
            child: Align(
              alignment: Alignment.centerRight,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  getCustomTextWithFontFamilyWidget(
                      "Pet Adoption\nMade Easy",
                      Colors.white,
                      getPercentSize(height, 11),
                      FontWeight.w500,
                      TextAlign.end,
                      2),
                  Container(
                    padding: EdgeInsets.symmetric(
                        vertical: getPercentSize(height, 4.5),
                        horizontal: getWidthPercentSize(context, 4)),
                    margin: EdgeInsets.only(top: getPercentSize(height, 6)),
                    decoration: getDefaultDecorationWithColor(
                        Colors.white, (radius / 1.5)),
                    child: getCustomTextWithFontFamilyWidget(
                      "Shop Now",
                      Colors.black,
                      getPercentSize(height, 7),
                      FontWeight.w400,
                      TextAlign.start,
                      1,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: EdgeInsets.all(getPercentSize(height, 5)),
                // margin: EdgeInsets.all(getPercentSize(height, 5)),
                child: Image.asset(
                  assetsPath + 'pet_3.png',
                  width: getScreenPercentSize(context, 20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  getBanner(double height, String img, {Color? color}) {
    if (color == null) {
      color = "#A193E2".toColor();
    }
    double width = double.infinity;

    double radius = getPercentSize(height, 7);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(radius)),
          // color: color,
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color!,
                color.withOpacity(0.9),
                color.withOpacity(0.5)
              ])),
      margin:
          EdgeInsets.symmetric(vertical: defMargin, horizontal: (padding / 2)),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: EdgeInsets.all(getPercentSize(height, 5)),
              child: Image.asset(
                assetsPath + img,
                width: getWidthPercentSize(context, 42),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: padding),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  getCustomTextWithFontFamilyWidget(
                      "Pet Adoption\nMade Easy",
                      Colors.white,
                      getPercentSize(height, 11),
                      FontWeight.w500,
                      TextAlign.start,
                      2),
                  Container(
                    padding: EdgeInsets.symmetric(
                        vertical: getPercentSize(height, 4.5),
                        horizontal: getWidthPercentSize(context, 4)),
                    margin: EdgeInsets.only(top: getPercentSize(height, 6)),
                    decoration: getDefaultDecorationWithColor(
                        Colors.white, (radius / 1.5)),
                    child: getCustomTextWithFontFamilyWidget(
                      "Shop Now",
                      Colors.black,
                      getPercentSize(height, 7),
                      FontWeight.w400,
                      TextAlign.start,
                      1,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  sellerList() {
    double height = getScreenPercentSize(context, 10);

    double width = getPercentSize(height, 80);
    double radius = getPercentSize(height, 5);

    return Container(
        margin: EdgeInsets.symmetric(horizontal: defMargin),
        child: ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: adoptList.length,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              Pet model = adoptList[index];
              return InkWell(
                child: getMaterialCell(context,
                    widget: Container(
                      margin:
                          EdgeInsets.only(top: padding, bottom: (padding / 2)),
                      padding: EdgeInsets.symmetric(horizontal: (padding / 2)),
                      height: height,
                      width: double.infinity,
                      decoration: getDecoration(radius),
                      child: Row(
                        children: [
                          Container(
                            height: width,
                            margin: EdgeInsets.only(right: padding),
                            width: width,
                            padding: EdgeInsets.all(getPercentSize(width, 10)),
                            decoration: BoxDecoration(
                                color: cellColor,
                                borderRadius: BorderRadius.all(Radius.circular(
                                    getPercentSize(width, 10)))),
                            child: Center(
                                child: Image.network(
                              assetsPath + model.image,
                            )),
                          ),
                          Expanded(
                              child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              getTextWidget(
                                  model.name,
                                  textColor,
                                  getPercentSize(height, 20),
                                  FontWeight.w500,
                                  TextAlign.center),
                              SizedBox(
                                height: getPercentSize(height, 5),
                              ),
                              getTextWidget(
                                  model.description,
                                  subTextColor,
                                  getPercentSize(height, 15),
                                  FontWeight.w300,
                                  TextAlign.center)
                            ],
                          )),
                          getTextWidget(
                              model.price.toString(),
                              primaryColor,
                              getPercentSize(height, 25),
                              FontWeight.bold,
                              TextAlign.center),
                        ],
                      ),
                    )),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AllPetPage()));
                },
              );
            }));
  }
}

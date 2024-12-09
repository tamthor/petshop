import 'package:flutter/material.dart';
import 'package:flutter_pet_shop/model/pet.dart';
import 'package:flutter_pet_shop/PetDetailPage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:figma_squircle/figma_squircle.dart';
import '../providers/pet_provider.dart';
import '../utils/Constant.dart';
import '../utils/CustomWidget.dart';
import '../utils/SizeConfig.dart';
import '../constant/app_constants.dart';


class CategoryDetailPage extends ConsumerWidget {
  final int categoryId;

  CategoryDetailPage({required this.categoryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petsAsync = ref.watch(petListProviderByCategory(categoryId));

    SizeConfig().init(context);
    double height = getScreenPercentSize(context, 40);
    double width = getWidthPercentSize(context, 40);
    double imgHeight = getPercentSize(height, 50);
    double remainHeight = height - imgHeight;
    double radius = getPercentSize(height, 5);
    double defMargin = getHorizontalSpace(context);
    double _crossAxisSpacing = 0;
    var _screenWidth = MediaQuery.of(context).size.width;
    var _crossAxisCount = 2;
    var _width = (_screenWidth - ((_crossAxisCount - 1) * _crossAxisSpacing)) /
        _crossAxisCount;
    var _aspectRatio = _width / height;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('Danh mục thú cưng'),
        backgroundColor: backgroundColor,
        elevation: 0,
      ),
      body: petsAsync.when(
        loading: () => Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (pets) => GridView.count(
          crossAxisCount: _crossAxisCount,
          shrinkWrap: true,
          padding: EdgeInsets.symmetric(horizontal: defMargin),
          scrollDirection: Axis.vertical,
          primary: false,
          crossAxisSpacing: defMargin,
          mainAxisSpacing: 0,
          childAspectRatio: _aspectRatio,
          children: List.generate(pets.length, (index) {
            Pet pet = pets[index];

            return InkWell(
              child: getMaterialCell(
                context,
                widget: Container(
                  width: width,
                  margin: EdgeInsets.symmetric(vertical: defMargin / 1.5),
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
                                    Image.network(
                                      '$IMAGE_BASE_URL${pet.image}',
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
                                        return Container(
                                          width: width,
                                          height: imgHeight,
                                          color: Colors.grey[300],
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.pets,
                                                size: 50,
                                                color: Colors.grey[500],
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
                              right: getPercentSize(width, 5)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: getCustomTextWidget(
                                      pet.name,
                                      textColor,
                                      getPercentSize(remainHeight, 11),
                                      FontWeight.w900,
                                      TextAlign.start,
                                      1,
                                    ),
                                  ),
                                  getCustomTextWidget(
                                    '${pet.price} vnđ',
                                    primaryColor,
                                    getPercentSize(remainHeight, 10),
                                    FontWeight.bold,
                                    TextAlign.start,
                                    1,
                                  ),
                                ],
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
                                      pet.description.length > 20
                                          ? pet.description.substring(0, 20) + '...'
                                          : pet.description,
                                      textColor,
                                      getPercentSize(remainHeight, 9.4),
                                      FontWeight.w500,
                                      TextAlign.start,
                                      1,
                                    ),
                                  ),
                                ],
                              ),
                              Expanded(
                                child: Container(),
                                flex: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
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
          }),
        ),
      ),
    );
  }
}

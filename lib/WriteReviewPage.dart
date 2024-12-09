import 'package:flutter/material.dart';
import 'package:flutter_pet_shop/MainPage.dart';
import 'package:flutter_pet_shop/utils/Constant.dart';
import 'package:flutter_pet_shop/utils/CustomWidget.dart';
import 'package:flutter_pet_shop/utils/SizeConfig.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'repository/review_reponsitory.dart';
import 'model/PetProductModel.dart';
import 'model/ReviewModel.dart';
import 'repository/profile_repository.dart';
import 'model/profile.dart';

import 'generated/l10n.dart';

class WriteReviewPage extends StatefulWidget {
  final PetProduct petProduct; // Thêm tham số này

  const WriteReviewPage({Key? key, required this.petProduct}) : super(key: key);
  @override
  _WriteReviewPage createState() {
    return _WriteReviewPage();
  }
}

class _WriteReviewPage extends State<WriteReviewPage> {
  final ReviewReponsitory reviewReponsitory = ReviewReponsitory();
  String reviewText = '';
  double rating = 0;
  final ProfileRepository profileRepository = ProfileRepository();
  int? userId; // Biến để lưu ID của người dùng

  @override
  void initState() {
    super.initState();
    _fetchUserProfile(); // Gọi phương thức để lấy thông tin người dùng
    setState(() {});
  }

  Future<void> _fetchUserProfile() async {
    try {
      Profile? profile = await profileRepository.getProfile();
      if (profile != null) {
        setState(() {
          userId = profile.id; // Lưu ID của người dùng
        });
      } else {
        print('No profile found');
      }
    } catch (e) {
      print('Error fetching user profile: $e');
    }
  }

  Future<bool> _requestPop() {
    Navigator.of(context).pop();
    return new Future.value(true);
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Xác nhận'),
          content: Text('Bạn có chắc chắn muốn gửi đánh giá không?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog
              },
              child: Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog
                _submitReview(); // Gọi phương thức gửi đánh giá
              },
              child: Text('Xác nhận'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitReview() async {
    if (reviewText.isEmpty || rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng nhập đánh giá và chọn xếp hạng.')),
      );
      return;
    }

    ReviewModel newReview = ReviewModel(
      userId: userId,
      productId: int.parse(widget.petProduct.id),
      rating: rating.toInt(),
      comment: reviewText,
    );

    try {
      await reviewReponsitory.createReview(newReview);
      _showThankYouDialog(); // Hiển thị dialog cảm ơn
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gửi đánh giá thất bại: $e')),
      );
    }
  }

  void _showThankYouDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cảm ơn bạn!'),
          content: Text('Cảm ơn bạn đã đánh giá sản phẩm.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => MainPage()), // Quay lại MainPage
                );
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    setThemePosition();
    double margin = getHorizontalSpace(context);
    double icon = getScreenPercentSize(context, 3.5);
    return WillPopScope(
        child: Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            elevation: 0,
            centerTitle: true,
            toolbarHeight: 0,
            backgroundColor: backgroundColor,
            title: getAppBarText(context, S.of(context).writeReviewPage),
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
            child: Container(
              margin: EdgeInsets.only(
                  // left: margin,
                  // right: margin,
                  // top: margin,
                  bottom: MediaQuery.of(context).size.width * 0.01),
              child: ListView(
                children: [

                  getAppBar(context, S.of(context).writeReviewPage,function: (){
                    _requestPop();
                  }, isBack: true),

                  Align(
                    alignment: Alignment.center,
                    child: Image.asset(
                      assetsPath + 'rate.png',
                      height: SizeConfig.safeBlockVertical! * 25,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: margin, bottom: margin),
                    child: Align(
                      alignment: Alignment.center,
                      child: RatingBar.builder(
                        itemSize: icon,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        tapOnlyMode: true,
                        updateOnDrag: true,
                        itemPadding: EdgeInsets.symmetric(horizontal: margin),
                        itemBuilder: (context, _) => Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: icon,
                        ),
                        onRatingUpdate: (newRating) {
                          rating = newRating;
                        },
                      ),
                    ),
                  ),
                  // Hiển thị thông tin sản phẩm
                  Container(
                    margin: EdgeInsets.only(bottom: getScreenPercentSize(context, 2)),
                    child: Column(
                      children: [
                        // Tạo một widget cho từng sản phẩm
                        _buildProductCard(widget.petProduct),
                      ],
                    ),
                  ),
                  getMaterialCell(context,widget: Container(
                    padding: EdgeInsets.all(margin),
                    margin: EdgeInsets.symmetric(vertical: margin,horizontal: margin),

                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                            Radius.circular(getScreenPercentSize(context, 1.2))),
                        
                        
                        color: backgroundColor),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Thêm trường nhập liệu cho reviewText
                  Padding(
                    padding: EdgeInsets.only(top: margin, bottom: margin),
                    child: TextField(
                      maxLines: 3, // Cho phép nhập nhiều dòng
                      onChanged: (value) {
                        reviewText = value; // Cập nhật reviewText khi người dùng nhập
                      },
                      style: TextStyle(
                        fontFamily: fontFamily,
                        color: textColor,
                        fontWeight: FontWeight.w400,
                        fontSize: getScreenPercentSize(context, 1.5),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter your review here...', // Gợi ý cho người dùng
                        contentPadding: EdgeInsets.all(margin),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: subTextColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                      ],
                    ),
                  )),
                  Container(
                    margin: EdgeInsets.only(top: (margin/2)),
                    child: getButtonWidget(context, "Submit", primaryColor, () async {
                      _showConfirmationDialog();
                    }),
                  ),

                  

                ],
              ),
            ),
          ),
        ),
        onWillPop: _requestPop);
  }
  // Widget để hiển thị thông tin sản phẩm
  Widget _buildProductCard(PetProduct petProduct) {
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
                  '\$${petProduct.price}',
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
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pet_shop/EditProfilePage.dart';
import 'package:flutter_pet_shop/utils/Constant.dart';
import 'package:flutter_pet_shop/utils/CustomWidget.dart';
// import 'package:flutter_pet_shop/utils/DataFile.dart';
import 'package:flutter_pet_shop/utils/SizeConfig.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../constant/apilist.dart';
import '../constant/enum.dart';
import '../providers/profile_provider.dart';
import '../constant/app_constants.dart';

class UpdateProfilePage extends ConsumerStatefulWidget {
  UpdateProfilePage();

  @override
  _UpdateProfilePageState createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends ConsumerState<UpdateProfilePage> {
  @override
  void initState() {
    super.initState();
    // Thay thế setInitialProfile bằng fetchProfile
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileProvider.notifier).fetchProfile();
    });
  }

  Future<bool> _requestPop() {
    Navigator.of(context).pop();
    return new Future.value(true);
  }

  XFile? _image;
  final picker = ImagePicker();




  getProfileImage() {
    if (_image != null && _image!.path.isNotEmpty) {
      return Image.file(
        File(_image!.path),
        fit: BoxFit.cover,
      );
    } else {
      // Lấy ảnh từ profile state
      final profileState = ref.watch(profileProvider);
      final photoUrl = profileState.profile.photo;
      
      if (photoUrl.isNotEmpty) {
        // Xử lý URL ảnh
        final fullPhotoUrl = photoUrl.startsWith('http') 
          ? photoUrl 
          : '$IMAGE_BASE_URL$photoUrl';
          
        print('Loading profile image from: $fullPhotoUrl'); // Debug log
        
        return Image.network(
          fullPhotoUrl,  // Sử dụng URL đầy đủ
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('Error loading profile image: $error'); // Debug log
            return Image.asset(
              assetsPath + "doraemon.png",
              fit: BoxFit.cover,
            );
          },
        );
      } else {
        // Ảnh mặc định khi không có photo URL
        return Image.asset(
          assetsPath + "doraemon.png",
          fit: BoxFit.cover,
        );
      }
    }
  }

  double defaultMargin=0;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final profileState = ref.watch(profileProvider);

    // Thêm loading indicator khi đang fetch
    if (profileState.updateStatus == UpdateStatus.updating) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    double profileHeight = getScreenPercentSize(context, 12);
     defaultMargin = getHorizontalSpace(context);




    return WillPopScope(
        child: Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            elevation: 0,
            toolbarHeight: 0,
            centerTitle: true,
            backgroundColor: backgroundColor,
            // title: getAppBarText(context,S.of(context).editProfiles),
            // leading: Builder(
            //   builder: (BuildContext context) {
            //     return IconButton(
            //       icon: getAppBarIcon(),
            //       onPressed: _requestPop,
            //     );
            //   },
            // ),
          ),



          //
          // bottomNavigationBar: getBottomText(
          //     context, S.of(context).save, () {
          //   Navigator.of(context).pop(true);
          // }),

          body: Container(
            child: Column(
              children: [

                getAppBar(context, "Profile",isBack: true,function: (){
                  _requestPop();
                }),

                SizedBox(height: getScreenPercentSize(context, 2),),
                Expanded(
                  child: Column(
          children: [
            if (profileState.updateStatus == UpdateStatus.updating)
              CircularProgressIndicator(),
            if (profileState.updateStatus == UpdateStatus.failure)
              Text(
                profileState.errorMessage ?? 'Có lỗi xảy ra!',
                style: TextStyle(color: Colors.red),
              ),
            GestureDetector(
              onTap: () {
                ref
                    .read(profileProvider.notifier)
                    .updateAvatar('new_avatar_url');
              },
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: EdgeInsets.only(top: defaultMargin),
                  height: profileHeight,
                  width: profileHeight,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: Material(
                      color: primaryColor,
                      child: getProfileImage(),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: ListTile(
                        leading: Icon(Icons.person, color: primaryColor),
                        title: Text(
                          'Full Name',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(profileState.profile.full_name),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: ListTile(
                        leading: Icon(Icons.phone, color: primaryColor),
                        title: Text(
                          'Phone',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(profileState.profile.phone),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: ListTile(
                        leading: Icon(Icons.home, color: primaryColor),
                        title: Text(
                          'Address',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(profileState.profile.address),
                      ),
                    ),
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  //   child: Card(
                  //     elevation: 2,
                  //     shape: RoundedRectangleBorder(
                  //       borderRadius: BorderRadius.circular(8.0),
                  //     ),
                  //     child: ListTile(
                  //       leading: Icon(Icons.account_circle, color: primaryColor),
                  //       title: Text(
                  //         'Username',
                  //         style: TextStyle(fontWeight: FontWeight.bold),
                  //       ),
                  //       subtitle: Text(profileState.profile.username),
                  //     ),
                  //   ),
                  // ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: ListTile(
                        leading: Icon(Icons.email, color: primaryColor),
                        title: Text(
                          'Email',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(profileState.profile.email),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            // ElevatedButton(
            //   onPressed: profileState.updateStatus == UpdateStatus.updating
            //       ? null
            //       : () async {
            //           await ref.read(profileProvider.notifier).saveProfile();
            //           if (profileState.updateStatus == UpdateStatus.success) {
            //             ScaffoldMessenger.of(context).showSnackBar(
            //               SnackBar(content: Text('Profile updated!')),
            //             );
            //           }
            //         },
            //   child: Text('Cập nhật'),
            // ),
          ],
        ),
                  flex: 1,
                ),


                Container(
                  margin: EdgeInsets.only(top: (defaultMargin/2)),
                  child: getButtonWidget(context, "Edit profile", primaryColor, () async {
                    // Chờ cho đến khi EditProfilePage hoàn thành
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EditProfilePage()),
                    );
                    
                    // Sau khi quay lại, fetch profile mới
                    if (mounted) {
                      ref.read(profileProvider.notifier).fetchProfile();
                    }
                  }),
                )
                
              ],
            ),
          ),
        ),
        onWillPop: _requestPop);
  }


  Widget getEditProfileTextFiledWidget(BuildContext context, String s,
      TextEditingController textEditingController) {
    double height = getScreenPercentSize(context, 7);

    double fontSize = getPercentSize(height, 27);

    return Container(

      height: getScreenPercentSize(context, 6),

      alignment: Alignment.centerLeft,

      // decoration: ShapeDecoration(
      //   color: cellColor,
      //
      //   // shadows: [BoxShadow(
      //   //     color: textColor.withOpacity(0.1),
      //   //     blurRadius: 2,
      //   //     spreadRadius: 1,
      //   //     offset: Offset(0, 4))],
      //   shape: SmoothRectangleBorder(
      //     side: BorderSide(color: primaryColor.withOpacity(0.5), width: 0.3),
      //     borderRadius: SmoothBorderRadius(
      //       cornerRadius: radius,
      //       cornerSmoothing: 0.8,
      //     ),
      //   ),
      // ),



      child: TextField(
        maxLines: 1,
        controller: textEditingController,
        textAlign: TextAlign.start,
        enabled: false,
        textAlignVertical: TextAlignVertical.center,
        style: TextStyle(
            fontFamily: fontFamily,
            color: textColor,
            fontWeight: FontWeight.w400,
            fontSize: fontSize),
        decoration: InputDecoration(
            contentPadding:
            EdgeInsets.zero,
            // border: InputBorder.none,
            // focusedBorder: InputBorder.none,
            // enabledBorder: InputBorder.none,
            // errorBorder: InputBorder.none,
            // disabledBorder: InputBorder.none,

            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: borderColor,width: 0.5),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: borderColor,width: 0.5),
            ),


            hintText: s,
            suffixIcon: Icon(
              Icons.add,
              color: Colors.transparent,
              size: getPercentSize(height, 40),
            ),
            hintStyle: TextStyle(
                fontFamily: fontFamily,
                color: subTextColor,
                fontWeight: FontWeight.w400,
                fontSize: fontSize)),
      ),
    );
  }



  getTitle(String string){
    return Container(
      margin: EdgeInsets.only(top: getScreenPercentSize(context,3)),
      child: getTextWidget(string, textColor,getScreenPercentSize(context, 1.8),
          FontWeight.w600, TextAlign.start),
    );
  }

}

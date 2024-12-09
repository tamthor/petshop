import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pet_shop/utils/Constant.dart';
import 'package:flutter_pet_shop/utils/CustomWidget.dart';
// import 'package:flutter_pet_shop/utils/DataFile.dart';
import 'package:flutter_pet_shop/utils/SizeConfig.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constant/enum.dart';
import '../providers/profile_provider.dart';
// import '../model/profile.dart';

// import 'model/AddressModel.dart';
import '../constant/app_constants.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  @override
  _EditProfilePage createState() {
    return _EditProfilePage();
  }
}

class _EditProfilePage extends ConsumerState<EditProfilePage> {
  // List<AddressModel> addressList = DataFile.getAddressList();

  late TextEditingController fullNameController;
  late TextEditingController newAdressController;

  @override
  void initState() {
    super.initState();
    // addressList = DataFile.getAddressList();

    final profile = ref.read(profileProvider).profile;
    fullNameController = TextEditingController(text: profile.full_name);
    newAdressController = TextEditingController(text: profile.address);

    setState(() {});
  }

  Future<bool> _requestPop() {
    Navigator.of(context).pop();
    return new Future.value(true);
  }

  XFile? _image;
  final picker = ImagePicker();

  _imgFromGallery() async {
    XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = image;
      });
      
      // Upload ảnh khi người dùng chọn xong
      try {
        await ref.read(profileProvider.notifier).uploadAndUpdatePhoto(File(image.path));
        
        final profileState = ref.read(profileProvider);
        if (profileState.updateStatus == UpdateStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Cập nhật ảnh đại diện thành công!'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.green,
            ),
          );
        } else if (profileState.updateStatus == UpdateStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Cập nhật ảnh thất bại: ${profileState.errorMessage}'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi tải ảnh lên: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  getProfileImage() {
    if (_image != null && _image!.path.isNotEmpty) {
      return Image.file(
        File(_image!.path),
        fit: BoxFit.cover,
      );
    } else {
      final profile = ref.watch(profileProvider).profile;
      if (profile.photo.isNotEmpty) {
        return Image.network(
          profile.photo.startsWith('http') 
            ? profile.photo 
            : IMAGE_BASE_URL + profile.photo,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('Error loading image: $error');
            return Image.asset(
              assetsPath + "doraemon.png",
              fit: BoxFit.cover,
            );
          },
        );
      } else {
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



    double profileHeight = getScreenPercentSize(context, 12);
     defaultMargin = getHorizontalSpace(context);
    double editSize = getPercentSize(profileHeight, 26);




    return WillPopScope(
        child: Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            elevation: 0,
            toolbarHeight: 0,
            centerTitle: true,
            backgroundColor: backgroundColor,
          ),

          body: GestureDetector(
            onTap: (){
              FocusScope.of(context).unfocus();
            },
            child: Container(
              child: Column(
                children: [

                  getAppBar(context, "Edit Profile",isBack: true,function: (){
                    _requestPop();
                  }),

                  SizedBox(height: getScreenPercentSize(context, 2),),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.symmetric(horizontal: defaultMargin),
                      children: [
                        Container(
                            height: profileHeight + (profileHeight / 5),
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: Stack(
                                children: <Widget>[




                                  Align(
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
                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    child: InkWell(
                                      child: Container(
                                        margin: EdgeInsets.only(
                                            left: getScreenPercentSize(
                                                context, 9),
                                            bottom:
                                            getScreenPercentSize(
                                                context, 1.6)),
                                        height: editSize,
                                        width: editSize,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white,
                                            boxShadow: [
                                              BoxShadow(
                                                  color: primaryColor.withOpacity(0.1),
                                                  blurRadius: 4,
                                                  spreadRadius: 3,
                                                  offset: Offset(0, 3))
                                            ],
                                          ),
                                          child: Center(
                                            child: Image.asset(
                                              assetsPath+"edit.png",
                                              color: primaryColor,
                                              height: getPercentSize(
                                                  editSize, 55),
                                            ),
                                          ),
                                        ),
                                      ),
                                      onTap: () async {
                                        _imgFromGallery();
                                      },
                                    ),
                                  )
                                ],
                              ),
                            )),


                        SizedBox(height: (defaultMargin*2),),


                        getEditProfileTextFiledWidget(context, "Full Name",
                            fullNameController),

                        getEditProfileTextFiledWidget(context, "Address",
                            newAdressController),

                      ],
                    ),
                    flex: 1,
                  ),


                  Container(
                    margin: EdgeInsets.only(top: (defaultMargin / 2)),
                    child: getButtonWidget(context, "Save", primaryColor, () async {
                      ref.read(profileProvider.notifier).updatefull_name(fullNameController.text);
                      ref.read(profileProvider.notifier).updateAddress(newAdressController.text);
                      await ref.read(profileProvider.notifier).saveProfile();

                      final profileState = ref.read(profileProvider);
                      if (profileState.updateStatus == UpdateStatus.success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Cập nhật thành công!'),
                            duration: Duration(seconds: 2),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else if (profileState.updateStatus == UpdateStatus.failure) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Cập nhật thất bại: ${profileState.errorMessage}'),
                            duration: Duration(seconds: 2),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }),
                  )

                ],
              ),
            ),
          ),
        ),
        onWillPop: _requestPop);
  }





  getTitle(String string){
    return Container(
      margin: EdgeInsets.only(top: getScreenPercentSize(context,3)),
      child: getTextWidget(string, textColor,getScreenPercentSize(context, 1.8),
          FontWeight.w600, TextAlign.start),
    );
  }


}

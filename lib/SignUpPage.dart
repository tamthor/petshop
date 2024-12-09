import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_pet_shop/customView/CountryCodePicker.dart';
import 'package:flutter_pet_shop/utils/Constant.dart';
import 'package:flutter_pet_shop/utils/CustomWidget.dart';
import 'package:flutter_pet_shop/utils/SizeConfig.dart';
import 'SignInPage.dart';
import 'generated/l10n.dart';
import '../providers/registration_provider.dart'; // Import the registration provider

class SignUpPage extends ConsumerStatefulWidget {
  @override
  _SignUpPage createState() {
    return _SignUpPage();
  }
}

class _SignUpPage extends ConsumerState<SignUpPage> {
  bool isRemember = false;
  int themeMode = 0;
  TextEditingController textEmailController = TextEditingController();
  TextEditingController textNameController = TextEditingController();
  TextEditingController textPasswordController = TextEditingController();
  TextEditingController textPhoneController = TextEditingController(); // Add phone controller
  TextEditingController textAddressController = TextEditingController(); // Add address controller
  TextEditingController textDescriptionController = TextEditingController(); // Add description controller

  Future<bool> _requestPop() {
    Navigator.of(context).pop();
    return Future.value(false);
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 0), () {
      setThemePosition(context: context);
      setState(() {});
    });
  }

  FocusNode myFocusNode = FocusNode();
  bool isAutoFocus = false;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    // double height = getScreenPercentSize(context, 7);

    final registrationStatus = ref.watch(registrationProvider);

    ref.listen<RegistrationStatus>(registrationProvider, (previous, next) {
      if (next == RegistrationStatus.success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignInPage()),
        );
      } else if (next == RegistrationStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration Failed. Please try again.')),
        );
      }
    });

    return WillPopScope(
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: backgroundColor,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: backgroundColor,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
          title: Text(""),
          leading: GestureDetector(
            onTap: () {
              _requestPop();
            },
            child: Icon(
              Icons.keyboard_backspace,
              color: textColor,
            ),
          ),
        ),
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: getHorizontalSpace(context)),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: Image.asset(
                        assetsPath + "splash_icon.png",
                        height: getScreenPercentSize(context, 7.5),
                        color: primaryColor,
                      ),
                    ),
                    SizedBox(height: getScreenPercentSize(context, 3)),
                    getTextWithFontFamilyWidget(
                      "Sign Up",
                      textColor,
                      getScreenPercentSize(context, 3),
                      FontWeight.w400,
                      TextAlign.left,
                    ),
                    SizedBox(height: getScreenPercentSize(context, 1)),
                    getTextWidget(
                      "Create Account for meet now Friends!",
                      textColor,
                      getScreenPercentSize(context, 1.9),
                      FontWeight.w400,
                      TextAlign.left,
                    ),
                    SizedBox(height: getScreenPercentSize(context, 2.5)),
                    getDefaultTextFiledWidget(
                      context, "Full Name", Icons.account_circle_outlined, textNameController),
                    getDefaultTextFiledWidget(
                      context, "Email", Icons.mail_outline, textEmailController),
                    getPasswordTextFiled(
                      context, "Password", textPasswordController),
                    getDefaultTextFiledWidget(
                      context, "Phone", Icons.phone, textPhoneController),
                    getDefaultTextFiledWidget(
                      context, "Address", Icons.home, textAddressController), // Add address field
                    getDefaultTextFiledWidget(
                      context, "Description", Icons.description, textDescriptionController), // Add description field
                    SizedBox(height: getScreenPercentSize(context, 1.5)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              isTermsCondition = !isTermsCondition;
                            });
                          },
                          child: Container(
                            height: getScreenPercentSize(context, 3),
                            width: getScreenPercentSize(context, 3),
                            decoration: BoxDecoration(
                              border: Border.all(color: primaryColor.withOpacity(0.4), width: 1),
                              color: isTermsCondition ? primaryColor : Colors.transparent,
                              borderRadius: BorderRadius.all(Radius.circular(getScreenPercentSize(context, 0.5))),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.check,
                                size: getScreenPercentSize(context, 2.5),
                                color: isTermsCondition ? Colors.white : Colors.transparent,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 5),
                        getTextWidget('I agree with ', textColor,
                            getScreenPercentSize(context, 1.8), FontWeight.w600, TextAlign.center),
                        SizedBox(width: 5),
                        getTextWidget("Terms", primaryColor,
                            getScreenPercentSize(context, 1.8), FontWeight.w600, TextAlign.center),
                        getTextWidget(" & ", textColor,
                            getScreenPercentSize(context, 1.8), FontWeight.w600, TextAlign.center),
                        getTextWidget("Condition", primaryColor,
                            getScreenPercentSize(context, 1.8), FontWeight.w600, TextAlign.center),
                      ],
                    ),
                    SizedBox(height: getScreenPercentSize(context, 3)),
                    if (registrationStatus == RegistrationStatus.loading)
                      Center(
                        child: CircularProgressIndicator(),
                      )
                    else
                      getButtonWithoutSpaceWidget(context, "Sign Up", primaryColor, () {
                        if (isTermsCondition) {
                          ref.read(registrationProvider.notifier).register(
                            textEmailController.text,
                            textPasswordController.text,
                            textNameController.text,
                            textPhoneController.text,
                            textAddressController.text, // Pass address
                            textDescriptionController.text, // Pass description
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Please agree to the terms and conditions.')),
                          );
                        }
                      }),
                  ],
                ),
                flex: 1,
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: EdgeInsets.only(bottom: getScreenPercentSize(context, 2)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      getTextWidget(S.of(context).youHaveAnAlreadyAccount, textColor,
                          getScreenPercentSize(context, 2), FontWeight.w400, TextAlign.center),
                      SizedBox(width: 5),
                      InkWell(
                        child: getTextWidget("Sign In", primaryColor,
                            getScreenPercentSize(context, 2), FontWeight.w700, TextAlign.center),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SignInPage()));
                        },
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      onWillPop: _requestPop,
    );
  }

  bool isTermsCondition = false;
}

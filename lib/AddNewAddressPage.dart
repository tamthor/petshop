import 'package:flutter/material.dart';
import 'package:flutter_pet_shop/utils/Constant.dart';
import '../repository/address_repository.dart';
import 'package:flutter_pet_shop/utils/CustomWidget.dart';
import '../model/AdressesModel.dart';
import 'providers/profile_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddNewAddressPage extends ConsumerStatefulWidget {
  @override
  _AddressPageState createState() => _AddressPageState();
}

class _AddressPageState extends ConsumerState<AddNewAddressPage> {
  final _formKey = GlobalKey<FormState>();
  final _addressRepository = AddressRepository();

  // Các biến để lưu dữ liệu biểu mẫu
  String? _addressLine1;
  String? _addressLine2;
  String? _city;
  String? _state;
  String? _postalCode;
  String? _phoneNumber;
  bool? _isDefault = false;

  Future<void> _saveAddress() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        // Gửi yêu cầu tạo địa chỉ
        AddressModel address = await _addressRepository.createAddress(
          addressLine1: _addressLine1!,
          addressLine2: _addressLine2,
          city: _city!,
          state: _state!,
          postalCode: _postalCode!,
          phoneNumber: _phoneNumber,
          isDefault: _isDefault,
        );

        // Hiển thị thông báo thành công với màu xanh lá cây
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Thêm địa chỉ thành công'),
            backgroundColor: Colors.green, // Màu nền xanh lá cây
          ),
        );

        // Gọi fetchProfile() sau khi thêm địa chỉ thành công
        ref.read(profileProvider.notifier).fetchProfile();

        Navigator.of(context).pop(address);
      } catch (e) {
        // Xử lý lỗi
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bạn chưa đăng nhập!!!'),
            backgroundColor: Colors.red, // Màu nền đỏ cho lỗi
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 60,
        backgroundColor: Colors.white,
        title: Text('Add New Address', style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0))),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.arrow_back, color: const Color.fromARGB(255, 0, 0, 0)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            );
          },
        ),
      ),
      body: Consumer(
        builder: (context, ref, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildTextFormField('Số nhà, đường...', (value) => _addressLine1 = value, true),
                    SizedBox(height: 10),
                    _buildTextFormField('Địa chỉ thêm', (value) => _addressLine2 = value, false),
                    SizedBox(height: 10),
                    _buildTextFormField('Thành phố,huyện,xã...', (value) => _city = value, true),
                    SizedBox(height: 10),
                    _buildTextFormField('Tỉnh', (value) => _state = value, true),
                    SizedBox(height: 10),
                    _buildTextFormField('Mã bưu điện', (value) => _postalCode = value, true),
                    SizedBox(height: 10),
                    _buildTextFormField('Số điện thoại', (value) => _phoneNumber = value, false),
                    SizedBox(height: 10),
                    // SwitchListTile(
                    //   title: Text(
                    //     'Set as Default Address',
                    //     style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)), // Change text color for better visibility
                    //   ),
                    //   value: _isDefault ?? false,
                    //   onChanged: (value) {
                    //     setState(() {
                    //       _isDefault = value;
                    //     });
                    //   },
                    //   activeColor: const Color.fromARGB(255, 155, 81, 207), // Change the active color of the switch
                    //   inactiveThumbColor: Colors.grey, // Change the inactive thumb color
                    //   inactiveTrackColor: Colors.grey[300], // Change the inactive track color
                    // ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        
        color: Colors.transparent,
        padding: EdgeInsets.only(bottom: 20),
        child: getButtonWidget(context, "Thêm địa chỉ", primaryColor, () {
          ref.read(profileProvider.notifier).fetchProfile();
          _saveAddress();
        }),
      ),
    );
  }

  Widget _buildTextFormField(String label, Function(String?) onSaved, bool isRequired) {
    return TextFormField(
      decoration: InputDecoration(
        hintText: label,
        hintStyle: TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.transparent),
        ),
        filled: true,
        fillColor: Colors.white,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.purple, width: 2),
        ),
      ),
      onSaved: onSaved,
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) {
          return '$label is required';
        }
        return null;
      },
    );
  }
}

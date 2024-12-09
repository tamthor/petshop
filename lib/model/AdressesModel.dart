class AddressModel {
  int? id;
  int? userId;
  String? addressLine1;
  String? addressLine2;
  String? city;
  String? state;
  String? postalCode;
  String? phoneNumber;
  bool? isDefault;

  AddressModel({
    this.id,
    this.userId,
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.state,
    this.postalCode,
    this.phoneNumber,
    this.isDefault,
  });

  // Từ JSON sang Model
  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'],
      userId: json['user_id'],
      addressLine1: json['address_line1'],
      addressLine2: json['address_line2'],
      city: json['city'],
      state: json['state'],
      postalCode: json['postal_code'],
      phoneNumber: json['phone_number'],
      isDefault: json['is_default'] == 1,
    );
  }

  // Từ Model sang JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'address_line1': addressLine1,
      'address_line2': addressLine2,
      'city': city,
      'state': state,
      'postal_code': postalCode,
      'phone_number': phoneNumber,
      'is_default': isDefault,
    };
  }
}
// import 'OrderDescModel.dart';

// lib/model/ProductOrderModel.dart
class ProductOrderModel {
  final int id; // ID của đơn hàng
  final int addressId; // ID của địa chỉ
  final int productId; // ID của thú cưng
  final double productPrice; // Giá thú cưng
  final int quantity; // Số lượng
  final double shippingCost; // Chi phí vận chuyển
  final double tax; // Thuế
  final double total; // Tổng tiền
  final DateTime createdAt; // Ngày tạo đơn hàng

  ProductOrderModel({
    required this.id,
    required this.addressId,
    required this.productId,
    required this.productPrice,
    required this.quantity,
    required this.shippingCost,
    required this.tax,
    required this.total,
    required this.createdAt,
  });

  factory ProductOrderModel.fromJson(Map<String, dynamic> json) {
  return ProductOrderModel(
    id: json['id'] ?? 0,
      addressId: json['address_id'] ?? 0,
      productId: json['product_id'] ?? 0,
      productPrice: (json['product_price'] ?? 0).toDouble(),
      shippingCost: (json['shipping_cost'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
      tax: (json['tax'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
    createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
  );
}

  // Phương thức để chuyển đổi ProductOrderModel thành JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'address_id': addressId,
      'product_id': productId,
      'product_price': productPrice,
      'quantity': quantity,
      'shipping_cost': shippingCost,
      'tax': tax,
      'total': total,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
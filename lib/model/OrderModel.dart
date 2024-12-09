// import 'OrderDescModel.dart';

// lib/model/OrderModel.dart
class OrderModel {
  final int id; // ID của đơn hàng
  final int addressId; // ID của địa chỉ
  final int petId; // ID của thú cưng
  final double petPrice; // Giá thú cưng
  final int quantity; // Số lượng
  final double shippingCost; // Chi phí vận chuyển
  final double tax; // Thuế
  final double total; // Tổng tiền
  final DateTime createdAt; // Ngày tạo đơn hàng

  OrderModel({
    required this.id,
    required this.addressId,
    required this.petId,
    required this.petPrice,
    required this.quantity,
    required this.shippingCost,
    required this.tax,
    required this.total,
    required this.createdAt,
  });

  // Phương thức để tạo đối tượng OrderModel từ JSON
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      addressId: json['address_id'],
      petId: json['pet_id'],
      petPrice: json['pet_price'].toDouble(),
      quantity: json['quantity'],
      shippingCost: json['shipping_cost'].toDouble(),
      tax: json['tax'].toDouble(),
      total: json['total'].toDouble(),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  // Phương thức để chuyển đổi OrderModel thành JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'address_id': addressId,
      'pet_id': petId,
      'pet_price': petPrice,
      'quantity': quantity,
      'shipping_cost': shippingCost,
      'tax': tax,
      'total': total,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
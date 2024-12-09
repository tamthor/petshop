import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../repository/add_to_cart_repotitory.dart';  // Import repository đã tạo
import '../model/PetProductModel.dart';  // Import model nếu cần

// Cart Repository Provider
final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return CartRepository();
});

// Cart Add Provider (để thêm sản phẩm vào giỏ)
final addToCartProvider = StateNotifierProvider<AddToCartNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(cartRepositoryProvider);
  return AddToCartNotifier(repository);
});

// StateNotifier cho việc thêm sản phẩm vào giỏ
class AddToCartNotifier extends StateNotifier<AsyncValue<void>> {
  final CartRepository _repository;

  AddToCartNotifier(this._repository) : super(const AsyncData(null));

  Future<String> addProductToCart(String productId) async {
    try {
      state = const AsyncLoading();  // Đặt trạng thái là loading khi bắt đầu

      // Gọi repository để thêm sản phẩm vào giỏ hàng
      final status = await _repository.addToCart(productId: productId);

      // Sau khi thêm thành công, cập nhật trạng thái
      state = const AsyncData(null);  // Cập nhật trạng thái thành công
      return status;
    } catch (e) {
      // Nếu có lỗi, cập nhật trạng thái với lỗi
      state = AsyncError(e, StackTrace.current);
      return "500"; // 500 ERROR
    }
  }
}

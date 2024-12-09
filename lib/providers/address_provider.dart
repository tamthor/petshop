// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../model/AdressesModel.dart';
// import '../repository/address_repository.dart';
// import 'auth_repository_provider.dart'; 

// class AddressNotifier extends StateNotifier<AsyncValue<List<AddressModel>>> {
//   final AddressRepository _addressRepository;

//   AddressNotifier(this._addressRepository) : super(const AsyncValue.data([]));

//   Future<void> addAddress(AddressModel address) async {
//     try {
//       state = const AsyncValue.loading();
//       await _addressRepository.createAddress(
//         addressLine1: address.addressLine1 ?? '',
//         addressLine2: address.addressLine2,
//         city: address.city ?? 'City', // Thay thế bằng dữ liệu thực tế nếu cần
//         state: address.state ?? 'State', // Thay thế bằng dữ liệu thực tế nếu cần
//         postalCode: address.postalCode ?? 'PostalCode', // Thay thế bằng dữ liệu thực tế nếu cần
//         phoneNumber: address.phoneNumber,
//         isDefault: address.isDefault,
//       );
//       // Nếu cần, có thể cập nhật danh sách địa chỉ sau khi thêm
//       // state = AsyncValue.data([...state.value!, address]);
//     } catch (error) {
//       state = AsyncValue.error(error, StackTrace.current);
//     }
//   }
// }

// final addressProvider = StateNotifierProvider<AddressNotifier, AsyncValue<List<AddressModel>>>((ref) {
//   final addressRepository = AddressRepository(ref.watch(authRepositoryProvider));
//   return AddressNotifier(addressRepository);
// });
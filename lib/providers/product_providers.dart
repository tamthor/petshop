import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/PetProductModel.dart';

// import '../model/pet.dart';
import '../repository/product_reponsitory.dart';
import '../model/pet_category.dart';

final productRepositoryProvider = Provider<PetProductRepository>((ref) {
  return PetProductRepository();
});

final petproductListProvider = FutureProvider<List<PetProduct>>((ref) async {
  final repository = ref.watch(productRepositoryProvider);
  return repository.fetchPetProducts();
});

final categoriesProvider = FutureProvider<List<PetCategory>>((ref) async {
  final repository = ref.watch(productRepositoryProvider);
  return repository.fetchProductCategories();
});

final petproductDetailProvider = FutureProvider.family<PetProduct, String>((ref, id) async {
  final repository = ref.watch(productRepositoryProvider);
  return repository.fetchPetProductDetail(id);
});


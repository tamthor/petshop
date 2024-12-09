import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/pet.dart';
import '../repository/pet_repository.dart';
import '../model/pet_category.dart';
import '../PetService.dart';


final petRepositoryProvider = Provider<PetRepository>((ref) {
  return PetRepository();
});

final petListProvider = FutureProvider<List<Pet>>((ref) async {
  final repository = ref.watch(petRepositoryProvider);
  return repository.fetchPets();
});

final categoriesProvider = FutureProvider<List<PetCategory>>((ref) async {
  final repository = ref.watch(petRepositoryProvider);
  return repository.fetchCategories();
});

final petDetailProvider = FutureProvider.family<Pet, String>((ref, id) async {
  final repository = ref.watch(petRepositoryProvider);
  return repository.fetchPetDetail(id);
});

final relatedPetsProvider = FutureProvider<List<Pet>>((ref) async {
  final repository = ref.watch(petRepositoryProvider);
  return repository.fetchPets();
});
final petListProviderByCategory = FutureProvider.family<List<Pet>, int>((ref, categoryId) async {
  return PetService().fetchPetsByCategory(categoryId);
});

// final productDetailProvider = FutureProvider.family<Pet, String>((ref, id) async {
//   final repository = ref.watch(petRepositoryProvider);
//   return repository.fetchPetDetail(id);
// });

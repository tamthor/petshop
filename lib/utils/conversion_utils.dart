import '../model/PetProductModel.dart';
import '../model/pet.dart';

Pet convertToPet(PetProduct petProduct) {
  return Pet(
    id: petProduct.id,
    name: petProduct.title,
    type: petProduct.summary ?? 'Dog',
    categoryId: petProduct.sold ?? '1',
    description: petProduct.description ?? 'No description available',
    price: petProduct.price.toDouble(),
    image: petProduct.photo,
    // Map other properties accordingly
  );
} 